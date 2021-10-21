#################################################################
#          Terraform file depends on variables.tf               #
#################################################################

#################################################################
#          Terraform file depends on locals.tf                  #
#################################################################

# Some remaining variables are still hardcoded, such Atlas shape 
# details. There are only used once, and most likely they are 
# not required to change

#################################################################
##################### MONGODB ATLAS SECTION #####################
#################################################################

provider "mongodbatlas" {
  # variable are provided via ENV
  # public_key = ""
  # private_key  = ""
  version = "~>0.7"
}

# Need a project
resource "mongodbatlas_project" "proj1" {
  name   = local.project_id
  org_id = var.atlas_organization_id
}

resource "mongodbatlas_network_container" "test" {
  project_id       = mongodbatlas_project.proj1.id
  atlas_cidr_block = local.atlas_cidr_block
  provider_name    = local.provider_name
}

# Peering for project Project
resource "mongodbatlas_network_peering" "test" {
  project_id             = mongodbatlas_project.proj1.id
  container_id           = mongodbatlas_network_container.test.container_id
  provider_name          = local.provider_name
  gcp_project_id         = local.google_project 
  network_name           = "default" 
}

# the following assumes a GCP provider is configured
data "google_compute_network" "default" {
  name = "default"
}

resource "google_compute_network_peering" "peering" {
  name         = "peering-gcp-terraform-test"
  network      = data.google_compute_network.default.self_link
  peer_network = "https://www.googleapis.com/compute/v1/projects/${mongodbatlas_network_peering.test.atlas_gcp_project_id}/global/networks/${mongodbatlas_network_peering.test.atlas_vpc_name}"
}

resource "mongodbatlas_project_ip_access_list" "test" {
    project_id = mongodbatlas_project.proj1.id
    # We are adding IP addres of 1 vm as a work around
    cidr_block = "${google_compute_instance.web.network_interface[0].network_ip}/32"
    # Ideal something like belw should be done, but that does not work
    # cidr_block = data.google_compute_network.default.ip_cidr_range

    comment    = "cidr block Google Cloud Compute Instance"
}

# resource "mongodbatlas_cluster" "this" {
#  name                  = local.cluster_name
#  project_id            = mongodbatlas_project.proj1.id

#  replication_factor           = 3
#  provider_backup_enabled      = true
#  auto_scaling_disk_gb_enabled = true
#  mongo_db_major_version       = "5.0"

#  provider_name               = local.provider_name
#  provider_instance_size_name = "M10"
#  # this provider specific, why?
#  provider_region_name        = local.region
# }

# output "atlasclusterstring" {
#    value = mongodbatlas_cluster.this.connection_strings[0].private_srv
# }

# # DATABASE USER
# resource "mongodbatlas_database_user" "user1" {
#   username           = local.admin_username
#   password           = var.admin_password
#   project_id         = mongodbatlas_project.proj1.id
#   auth_database_name = "admin"

#   roles {
#     role_name     = "readWriteAnyDatabase"
#     database_name = "admin"
#   }
#   labels {
#     key   = "Name"
#     value = local.admin_username
#   }
#   scopes {
#     name = mongodbatlas_cluster.this.name
#     type = "CLUSTER"
#   }
# }

# output "user1" {
#   value = mongodbatlas_database_user.user1.username
# }