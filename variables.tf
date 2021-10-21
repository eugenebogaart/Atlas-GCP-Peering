# Admin password provisioned for Atlas database user
variable "admin_password" {
  description = "Password for default users"
  type = string
}

variable "atlas_organization_id" {
  description = "Atlas organization id where to create project & link & project"
  type = string
}

variable "ssh_keys_data" {
  description = "Public key"
  type = string
}

variable "private_key_path" {
  description = "Private key path"
  type = string
}
