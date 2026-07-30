resource "aws_s3_bucket" "main" {
  bucket = "${var.project_name}-${var.name}-bucket"

  tags = merge(var.tags, {
    Name    = "${var.project_name}-${var.name}-bucket"
    Purpose = var.name
    }
  )
}

# Bật versioning
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Mã hoá server-side S3-managed SSE
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "public" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Thiết lập lifecycle cho versioning
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "old-versions-lifecycle"
    status = var.enable_lifecycle.old_version_lifecycle ? "Enabled" : "Disabled"

    filter {}

    # Chuyển version cũ sang storage class rẻ hơn sau X ngày
    # Không cần thiết cho backup bucket
    noncurrent_version_transition {
      noncurrent_days = var.noncurrent_version_transition_day.glacier_ir
      storage_class   = "GLACIER_IR"
    }

    noncurrent_version_transition {
      noncurrent_days = var.noncurrent_version_transition_day.deep_archive
      storage_class   = "DEEP_ARCHIVE"
    }

    # Xóa các object version cũ sau 30 ngày
    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_transition_day.expiration
    }

    # Dọn rác từ multipart upload thất bại
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  # Chuyển phiên bản hiện tại sau X ngày
  rule {
    id     = "current-versions-lifecycle"
    status = var.enable_lifecycle.current_version_lifecycle ? "Enabled" : "Disabled"

    filter {}

    transition {
      days          = var.current_version_transition_day.glacier_ir
      storage_class = "GLACIER_IR"
    }

    transition {
      days          = var.current_version_transition_day.deep_archive
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = var.current_version_transition_day.expiration
    }

    # Dọn rác từ multipart upload thất bại
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
