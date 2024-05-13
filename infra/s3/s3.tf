resource "aws_s3_bucket" "bucket" {
  bucket = "foo-doo-emr-container-scripts" // replace with your bucket name
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.bucket.bucket // reference to the bucket created above
  key    = "pyspark/" // replace with your object key
  source = "..\\pyspark\\emr_container_job_template.py" // replace with your local file path
  acl    = "private"
}