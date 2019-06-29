provider "aws" {
  region = "eu-west-2"
}

resource "random_string" "random" {
  length  = 8
  upper   = false
  number  = false
  special = false
}

resource "tls_private_key" "kops_ssh_key" {
  algorithm = "RSA"
}

resource "local_file" "file_kops_ssh_key_priv" {
  content  = "${tls_private_key.kops_ssh_key.private_key_pem}"
  filename = "${path.module}/kops.pem"
}

resource "local_file" "file_kops_ssh_key_pub" {
  content  = "${tls_private_key.kops_ssh_key.public_key_openssh}"
  filename = "${path.module}/kops.pem.pub"
}

resource "aws_key_pair" "kops_key" {
  key_name   = "kops-${random_string.random.result}-key"
  public_key = "${tls_private_key.kops_ssh_key.public_key_openssh}"
}

resource "aws_s3_bucket" "kops_state_bucket" {
  bucket = "kops-${random_string.random.result}.k8s.local"
  acl    = "private"
}

# ----------------------------------------
# Outputs
# ----------------------------------------
output "kops_state_bucket_name" {
  value = "${aws_s3_bucket.kops_state_bucket.bucket}"
}

output "kops_ssh_key_name" {
  value = "${aws_key_pair.kops_key.key_name}"
}
