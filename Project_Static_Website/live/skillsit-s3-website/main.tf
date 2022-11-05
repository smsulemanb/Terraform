provider "aws" {
  region="us-east-1" 
}

module "s3-website" {
  source = "../../modules/s3-website"

  bucket_name = "skillsit-s3-website2"
}

output "website_endpoint" {
  value = module.s3-website.website_endpoint
}

