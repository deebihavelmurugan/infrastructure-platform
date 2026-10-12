mock_provider "aws" {}

test "validates_explicit_public_and_private_controls" {
  variables {
    team_name   = "checkout"
    environment = "staging"
    buckets = [
      { name = "vault", public = false },
      { name = "cdn", public = true }
    ]
  }

  assert {
    condition     = aws_s3_bucket.bucket["vault"].tags["IsPublic"] == "false"
    error_message = "Vault bucket must be classified as private."
  }

  assert {
    condition     = length(aws_s3_bucket_policy.public_policy) == 1
    error_message = "Public policy should strictly be generated only for public buckets."
  }
}
