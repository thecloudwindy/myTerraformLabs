resource "aws_s3_bucket" "static_website" {
  bucket = "my-s3-bucket-${random_id.bucket_suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "allow_static_website_public_read" {
  bucket = aws_s3_bucket.static_website.id
  policy = jsonencode(
    {
      "Id" : "Policy1737202564494",
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "Stmt1737202563142",
          "Action" : "s3:*",
          "Effect" : "Allow",
          "Resource" : "${aws_s3_bucket.static_website.arn}/*",
          "Principal" : "*"
        }
      ]
    }
  )

  depends_on = [aws_s3_bucket.static_website, aws_s3_bucket_public_access_block.static_website]
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.static_website.id
  key    = "index.html"
  source = "files/index.html"
  etag   = filemd5("files/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "error_html" {
  bucket = aws_s3_bucket.static_website.id
  key    = "error.html"
  source = "files/error.html"
  etag   = filemd5("files/error.html")
  content_type = "text/html"
}
