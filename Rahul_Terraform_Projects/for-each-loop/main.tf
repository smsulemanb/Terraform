provider "aws" {
   region     = "eu-central-1"
}
resource "aws_instance" "ec2_example" {

   ami           = "ami-0767046d1677be5a0"
   instance_type =  "t2.micro"
   count = 1

   tags = {
           Name = "Terraform EC2"
   }
}
resource "aws_iam_user" "example" {
  for_each = var.user_names
  name  = each.value
}
variable "user_names" {
  description = "IAM usernames"
  type        = set(string)
  default     = ["user1", "user2", "user3"]
}