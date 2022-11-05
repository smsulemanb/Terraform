resource "aws_s3_bucket" "a1b1c1" {
  bucket = var.bucket_name

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}