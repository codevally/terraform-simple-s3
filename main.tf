resource "aws_kms_key" "mykey" {
   description             = "This key is used to encrypt bucket objects"
   deletion_window_in_days = 10
   tags = {
    Name        = "My KMS Key"
    Environment = "Sandbox"
    Owner       = "Narendra Yala"
  }
}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-1234"
  acl    = "private"
  
  tags = {
    Name        = "My S3 test bucket"
    Environment = "Sandbox"
    Owner       = "Narendra Yala"
  }
  
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.mykey.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
    
}
