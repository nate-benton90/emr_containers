resource "aws_s3_bucket" "emr-eks-scripts" {
  bucket = "foo-doo-who-emr-container-scripts" // replace with your bucket name
  acl    = "private"
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.emr-eks-scripts.bucket
  key    = "emr_container_job_template.py"
  source = "pyspark/emr_container_job_template.py"
  acl    = "private"
}
output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.emr-eks-scripts.arn
}
