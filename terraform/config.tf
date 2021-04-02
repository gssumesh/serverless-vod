terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "gssumesh"

    workspaces {
      prefix = "serverless-vod-"
    }
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = local.region
}