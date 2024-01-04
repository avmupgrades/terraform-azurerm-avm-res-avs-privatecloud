#create bastion
variable "create_bastion" {
    type = bool
    description = "Create a bastion resource to use for logging into the domain controller?  Defaults to false."
    default = false  
}

#domain fqdn
variable "domain_fqdn" {
    type = string
    description = "The fully qualified domain name to use when creating the domain controller. Defaults to test.local"
    default = "test.local"  
}

#domain netbios
variable "domain_netbios_name" {
    type = string
    description = "The Netbios name for the domain.  Default to test."
    default = "test"  
}

variable "domain_distinguished_name" {
    type = string
    description = "The distinguished name (DN) for the domain to use in ADCS. Defaults to DC=test,DC=local"
    default = "DC=test,DC=local"  
}

#DC sku
variable "dc_vm_sku" {
  type = string
  description = "The virtual machine sku size to use for the domain controller.  Defaults to Standard_D2_v4"
  default = "Standard_D2_v4"
}

variable "resource_group_name" {
  type = string
  description = "The name of the resource group where the dc will be installed."
}

variable "resource_group_location" {
    type = string
    description = "The region for the resource group where the dc will be installed."  
}

#names
#vm name
variable "dc_vm_name" {
    type = string
    description = "The name of the domain controller virtual machine."  
}
#bastion name
variable "bastion_name" {
    type = string
    description = "The name to use for the bastion resource"
    default = null  
}
#bastion pip name
variable "bastion_pip_name" {
    type = string
    description = "The name to use for the bastion public IP resource"
    default = null  
}

#subnet definitions
#bastion
variable "bastion_subnet_resource_id" {
  type = string
  description = "The Azure Resource ID for the subnet where the bastion will be connected."
  default = null
}
#domain controller
variable "dc_subnet_resource_id" {
    type = string
    default = "The Azure Resource ID for the subnet where the DC will be connected."  
}

variable "key_vault_resource_id" {
  type = string
  description = "The Azure Resource ID for the key vault where the DSC key and VM passwords will be stored."
}

variable "dc_dsc_script_url" {
    type = string
    description = "the github url for the raw DSC configuration script that will be used by the custom script extension."
    default = "https://raw.githubusercontent.com/Azure/terraform-azurerm-avm-res-avs-privatecloud/initial_development/examples/with_ad/templates/dc_windows_dsc.ps1"  
}