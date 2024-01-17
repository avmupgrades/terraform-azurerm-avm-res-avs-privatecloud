New-Item -Path 'c:\temp' -ItemType Directory -ErrorAction SilentlyContinue
set-location -Path 'c:\temp'

$cert = Get-ChildItem -Path "cert:\LocalMachine\My\$env:THUMBPRINT"
Export-Certificate -Cert $cert -FilePath .\dsc.cer
certutil -encode dsc.cer dsc64.cer

[DSCLocalConfigurationManager()]
Configuration lcmConfig {
    Node localhost
    {
        Settings
        {
            RefreshMode = 'Push'
            ActionAfterReboot = "ContinueConfiguration"
            RebootNodeIfNeeded = $true
            ConfigurationModeFrequencyMins = 15
            CertificateID = $env:THUMBPRINT
        }
    }
}

Write-Host "Creating LCM mof"
lcmConfig -InstanceName localhost -OutputPath .\lcmConfig
Set-DscLocalConfigurationManager -Path .\lcmConfig -Verbose

[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ("$env:ACTIVEDIRECTORYNETBIOS\$env:ADMINUSERNAME", (ConvertTo-SecureString "$env:ADMINPASSWORD" -AsPlainText -Force))

Configuration dc {
   
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DscResource -ModuleName DnsServerDsc
    Import-DscResource -ModuleName SecurityPolicyDsc
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DSCResource -ModuleName ActiveDirectoryCSDsc
    Import-DSCResource -Name WindowsFeature

    #[pscredential]$credObject = New-Object System.Management.Automation.PSCredential ($Node.ADMINUSERNAME, (ConvertTo-SecureString $Node.ADMINPASSWORD -AsPlainText -Force))

    Node localhost
    {
        #Add the domain services feature
        WindowsFeature 'ad-domain-services'
        {
            Name                 = 'ad-domain-services'
            Ensure               = 'Present'
            IncludeAllSubFeature = $true 
        }
        #add the RSAT tools for ADDS
        WindowsFeature 'rsat-adds'
        {
            Name                 = 'rsat-adds'
            Ensure               = 'Present'
        }
        #Add the AD DS powershell cmdlets
        WindowsFeature 'rsat-ad-powershell'
        {
            Name                 = 'rsat-ad-powershell'
            Ensure               = 'Present'
        }
        WaitForADDomain 'WaitForestAvailability'
        {
            DomainName = $Node.ActiveDirectoryFQDN
            Credential = $credObject

            DependsOn  = '[WindowsFeature]rsat-ad-powershell'
        }

        ADDomainController 'DomainControllerUsingExistingDNSServer'
        {
            DomainName                    = $Node.ActiveDirectoryFQDN
            Credential                    = $credObject
            SafeModeAdministratorPassword = $credObject
            IsGlobalCatalog               = $true
            Ensure                        = 'Present'
            InstallDns                    = $true

            DependsOn                     = '[WaitForADDomain]WaitForestAvailability'
        }
       
    }
}

$cd = @{
    AllNodes = @(    
        @{ 
            NodeName                  = "localhost"
            CertificateFile           = "C:\temp\dsc64.cer"
            Thumbprint                = $env:THUMBPRINT
            ActiveDirectoryFQDN       = $env:ACTIVEDIRECTORYFQDN
            ActiveDirectoryNETBIOS    = $env:ACTIVEDIRECTORYNETBIOS
        }
    ) 
}

dc -ConfigurationData $cd
Start-dscConfiguration -Path ./dc -Force
