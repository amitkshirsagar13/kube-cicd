variable "rowner" {
    description = "Process Owner for the resources"
    default = "terraform"
}

variable "rtags" {
    type = "map"
    description = "define new custom variable here"
    default = {
        resourceOwner = "terraform"
    }
}

variable "renvironment" {
  description = "Environment name for the Terraform."
  # If default value not provided, will be prompted at run time.
#  default = "dev_a"
}

variable "rgroup" {
  description = "Resource Group for execution"
  default = "dev"
}

variable "sgroup" {
  description = "Security Group for network"
  default = "dev"
}

variable "rlocation" {
    description = "Geo-Location of the cloud Resource"
    default = "West US"
}

variable "rnet" {
  description = "vnet name"
  default = "dev"
}
variable "rsubnet" {
  description = "Subnet name"
  default = "dev"
}
