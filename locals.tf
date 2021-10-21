locals {
  # Generic project prefix, to rename most components
  prefix                = "EB"    
  # New empty Atlas project name to create in organization
  project_id            = "${local.prefix}-GCP-Peered-project"
  # Atlas region, https://docs.atlas.mongodb.com/reference/google-gcp/
  region                = "EUROPE_WEST_4"
  # Atlas cluster name
  cluster_name		      = "${local.prefix}-Cluster"    
  # Atlas Pulic providor
  provider_name         = "GCP"
  # Atlas cidr block
  atlas_cidr_block      = "10.10.0.0/18"

  # Google Default Project
  google_project        = "eugene-bogaart-project"
  # Google Region
  google_region         = "europe-west4"  
  # Google Zone in Region
  google_zone           = "${local.google_region}-a"
  # Atlas database & vm user_name
  admin_username        = "demouser1"
  # Google vm size
  google_vm_size        = "e2-medium"
  # Google vm_name       
  google_vm_name        = "demo-peer"

  # Stuff to install in virtual machine
  python = [
      "sleep 10",
      "sudo apt-get -y update",
	    "sudo apt-get -y install python3-pip",
	    "sudo pip3 install pymongo==3.9.0",
	    "sudo pip3 install dnspython"
  ]
  mongodb = [
      "wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -",
      "echo 'deb [ arch=amd64,arm64 ] http://repo.mongodb.com/apt/ubuntu bionic/mongodb-enterprise/5.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-enterprise.list",
      "sudo apt-get update",
      "sudo apt-get install -y mongodb-enterprise mongodb-enterprise-shell mongodb-enterprise-tools"
  ]
}

terraform {
  required_version = ">= 0.13.05"
}
