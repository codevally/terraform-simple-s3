resource "aws_kms_key" "mykey" {
   description             = "This key is used to encrypt bucket objects"
   deletion_window_in_days = 10
}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-1234"
  acl    = "private"
  
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
    Owner       = "Narendra"
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
