# MongoDB Atlas project peered with Google Network

## What is new
* upgrade terrafrom to 0.13,  
* use google v3.89.0
* use mongodbatlas v0.9.1 
* create Azure vm with Mongo shell

## Background
Based on an small Proof of Concept to make Atlas available via VNet peering in Google in the same region, this script was generalized to automate all steps. Assumption was to automate each step, including the scripts to define custom roles for peering.  The documentation on how to do this in several manual steps is here: https://docs.atlas.mongodb.com/security-vpc-peering/

## Prerequisites:
* Authenticate into Google via CLI with: 
```
gcloud auth application-default login
```
* Have Terraform 0.13.6 installed
* Run: terraform init 

```
Initializing provider plugins...
- Finding latest version of hashicorp/google...
- Finding mongodb/mongodbatlas versions matching "~> 0.7"...
- Installing hashicorp/google v3.89.0...
- Installed hashicorp/google v3.89.0 (self-signed, key ID 34365D9472D7468F)
- Installing mongodb/mongodbatlas v0.9.1...
- Installed mongodb/mongodbatlas v0.9.1 (signed by a HashiCorp partner, key ID 2A32ED1F3AD25ABF)
```

## Config:
* Set up credential, as in section: "Configure Script - Credentials"
* Change basic parameters, as in file : locals.tf
* Run: terraform apply

## Todo <Oct 2021>:
* Modify Atlas Access list with Google ip_cdr_addr 


## Basic Terraform setup broken up in several files
* atlas.tf   creates Atlas side in a new project, Network peering and small cluster
* google.tf   creates Google side for Network peering, + one VM with Mongo shell installed
* locals.tf  here you can configure script to use meaning full name
* variables.tf  here you can attach credentials for Atlas, Google and SSH


## Configure Script - Credentials: "variables.tf"

To configure the providers, such as Atlas and Google, one needs credentials to gain access.
In case of MongoDB Atlas a public and private key pair is required. 
How to create an API key pair for an existing Atlas organization can be found here:
https://docs.atlas.mongodb.com/configure-api-access/#programmatic-api-keys
These keys are read in environment variables for safety. Alternatively these parameters
can be provide on the command line of the terraform invocation. The MONGODBATLAS provider will read
the 2 distinct variable, as below:

* MONGODB_ATLAS_PUBLIC_KEY=<PUBLICKEY>
* MONGODB_ATLAS_PRIVATE_KEY=<PRIVATEKEY>

Second a Google Cloud subscription is required. This sample use commandlin authentication via gcloud
You need to enable Google Cloud API for provisioning Compute and Network.
How is ot side of scope of this setup.

## Other configuration: "locals.tf"

In the locals resource of the locals.tf file, several parameters should be adapted to your needs
```
locals {
  # Generic project prefix, to rename most components
  prefix                = "EB"    
  # New empty Atlas project name to create in organization
  project_id            = "${local.prefix}-GCP-Peered-project"
  # Atlas region, https://docs.atlas.mongodb.com/reference/google-gcp/
  region                = "EUROPE_WEST_4"
  # Atlas cluster name
  cluster_name		    = "${local.prefix}-Cluster"    
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
```

## Give a go

In you favorite shell, run terraform apply and review the execution plan on what will be added, changed and detroyed. Acknowledge by typing: yes 

```
%>  terraform apply
```


## Known Bugs
* No for the moment
