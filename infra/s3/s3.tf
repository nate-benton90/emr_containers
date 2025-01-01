// Resources
resource "aws_s3_bucket" "emr-eks-scripts" {
  bucket = "foo-doo-who-emr-container-scripts" // Replace with your bucket name
}

resource "aws_s3_bucket_versioning" "emr_eks_scripts_versioning" {
  bucket = aws_s3_bucket.emr-eks-scripts.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.emr-eks-scripts.bucket
  key    = "emr_container_job_template.py"
  source = "pyspark/emr_container_job_template.py"
}

// Outputs
output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.emr-eks-scripts.arn
}
