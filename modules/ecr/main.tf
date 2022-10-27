resource "aws_ecr_repository" "repo" {
  
  count = length(var.ecr_respositories) > 0 ? length(var.ecr_respositories) : 0
  name                 = lookup(var.ecr_respositories[count.index], "repo_name", null)
  image_tag_mutability = lookup(var.ecr_respositories[count.index], "image_tag_mutability", var.image_tag_mutability)

  # name                 = var.name 
  # image_tag_mutability = var.image_tag_mutability

  # Encryption configuration
  dynamic "encryption_configuration" {
    for_each = local.encryption_configuration
    content {
      encryption_type = lookup(encryption_configuration.value, "encryption_type")
    }
  }

  # Image scanning configuration
  dynamic "image_scanning_configuration" {
    for_each = local.image_scanning_configuration
    content {
      scan_on_push = lookup(var.ecr_respositories[count.index], "image_scanning_enabled", var.image_scanning_enabled)
    }
  }

  # Timeouts
  dynamic "timeouts" {
    for_each = local.timeouts
    content {
      delete = lookup(timeouts.value, "delete")
    }
  }

  # Tags
  tags = var.tags

}

# Policy
# resource "aws_ecr_repository_policy" "policy" {
#   count      = var.policy == null ? 0 : 1
#   repository = aws_ecr_repository.repo.name
#   policy     = var.policy
# }

# Lifecycle policy
# resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
#   count      = var.lifecycle_policy == null ? 0 : 1
#   repository = aws_ecr_repository.repo.name
#   policy     = var.lifecycle_policy
# }

# KMS key
# resource "aws_kms_key" "kms_key" {
#   count       = var.encryption_type == "KMS" && var.kms_key == null ? 1 : 0
#   description = "${var.name} KMS key"
# }

# resource "aws_kms_alias" "kms_key_alias" {
#   count         = var.encryption_type == "KMS" && var.kms_key == null ? 1 : 0
#   name          = "alias/${var.name}Key"
#   target_key_id = aws_kms_key.kms_key[0].key_id
# }

locals {

  # Encryption configuration
  # If encryption type as KMS, use assigned KMS key or otherwise build a new key
  encryption_configuration = var.encryption_type != "AES-256" ? [] : [
    {
      encryption_type = "AES-256"
    }
  ]

  # Image scanning configuration
  # If no image_scanning_configuration block is provided, build one using the default values
  image_scanning_configuration = [
    {
      scan_on_push = lookup(var.image_scanning_configuration, "scan_on_push", null) == null ? var.scan_on_push : lookup(var.image_scanning_configuration, "scan_on_push")
    }
  ]

  # Timeouts
  # If no timeouts block is provided, build one using the default values
  timeouts = var.timeouts_delete == null && length(var.timeouts) == 0 ? [] : [
    {
      delete = lookup(var.timeouts, "delete", null) == null ? var.timeouts_delete : lookup(var.timeouts, "delete")
    }
  ]
}