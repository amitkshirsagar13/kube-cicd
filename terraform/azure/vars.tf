variable "region" {
  description = "The aws region where to deploy this code (e.g. us-east-1)."
  default = "us-east-1"
}

variable "location" {
  description = "The azure region where to deploy this code (e.g. West US)."
  default = "West US"
}

variable "environment" {
  description = "Environment name."
#  default = "dev_a"
}

variable "owner" {
    description = "Owner for the resources"
    default = "terraform"
}
variable "tagOwner" {
    type = "map"
    description = "define new custom variable here"
    default = {
        resourceOwner = "terraform"
    }
}
