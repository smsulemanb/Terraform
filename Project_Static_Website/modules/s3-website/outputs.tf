output "website_endpoint" {
  description = "The public url of this website."
  value = "${aws_s3_bucket.static_site2.website_endpoint}"
}