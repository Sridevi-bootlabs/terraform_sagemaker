resource "aws_sagemaker_domain" "example" {
  domain_name = "example"
  auth_mode   = "IAM"
  vpc_id      = "Default VPC"
  subnet_ids  = [aws_subnet.main.id]

  default_user_settings {
    execution_role = aws_iam_role.role21.arn
  }
}
resource "aws_iam_role" "role21" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "tag-value"
  }
}

# data "aws_iam_policy_document" "instance-assume-role-policy" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ec2.amazonaws.com"]
#     }
#   }
# }

# resource "aws_iam_role" "instance" {
#   name               = "instance_role"
#   path               = "/system/"
#   assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
# }


# resource "aws_iam_role" "example" {
#   name               = "example"
#   path               = "/"
#   assume_role_policy = data.aws_iam_policy_document.example.json
# }

# data "aws_iam_policy_document" "example" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["sagemaker.amazonaws.com"]
#     }
#   }
# }
resource "aws_sagemaker_app" "example" {
  domain_id         = aws_sagemaker_domain.example.id
  user_profile_name = aws_sagemaker_user_profile.example.user_profile_name
  app_name          = "example"
  app_type          = "JupyterServer"
}
resource "aws_sagemaker_user_profile" "example" {
  domain_id         = aws_sagemaker_domain.example.id
  user_profile_name = "example"
}
resource "aws_sagemaker_app_image_config" "test" {
  app_image_config_name = "example"

  kernel_gateway_image_config {
    kernel_spec {
      name = "example"
    }
  }
}
resource "aws_sagemaker_studio_lifecycle_config" "example" {
  studio_lifecycle_config_name     = "example"
  studio_lifecycle_config_app_type = "JupyterServer"
  studio_lifecycle_config_content  = base64encode("echo Hello")
}
resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "lc" {
  name      = "foo"
  on_create = base64encode("echo foo")
  on_start  = base64encode("echo bar")
}

# resource "aws_sagemaker_notebook_instance" "ni" {
#   name          = "my-notebook-instance"
#   role_arn      = aws_iam_role.role.arn
#   instance_type = "ml.t2.medium"

#   tags = {
#     Name = "foo"
#   }
# }

resource "aws_sagemaker_code_repository" "example" {
  code_repository_name = "my-notebook-instance-code-repo"

  git_config {
    repository_url = "https://github.com/hashicorp/terraform-provider-aws.git"
  }
}
resource "aws_sagemaker_notebook_instance" "ni" {
  name                    = "my-notebook-instance"
  role_arn                = aws_iam_role.role21.arn
  instance_type           = "ml.t2.medium"
  default_code_repository = aws_sagemaker_code_repository.example.code_repository_name

  tags = {
    Name = "foo"
  }
  depends_on = [
    aws_iam_role.role21
  ]
}

resource "aws_sagemaker_model" "example" {
  name               = "my-model"
  execution_role_arn = aws_iam_role.role21.arn

  primary_container {
    image = data.aws_sagemaker_prebuilt_ecr_image.test.registry_path
  }
  depends_on = [
    aws_iam_role.role21
  ]
}

# resource "aws_iam_role" "example" {
#   assume_role_policy = data.aws_iam_policy_document.assume_role.json
# }

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["sagemaker.amazonaws.com"]
    }
  }
}

data "aws_sagemaker_prebuilt_ecr_image" "test" {
  repository_name = "kmeans"
}

resource "aws_sagemaker_model_package_group" "example" {
  model_package_group_name = "example"
}

resource "aws_sagemaker_endpoint_configuration" "ec" {
  name = "my-endpoint-config"

  production_variants {
    variant_name           = "variant-1"
    model_name             = aws_sagemaker_model.example.name
    initial_instance_count = 1
    instance_type          = "ml.t2.medium"
  }

  tags = {
    Name = "foo"
  }
}

# resource "aws_sagemaker_endpoint" "e" {
#   name                 = "my-endpoint"
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.ec.name

#   tags = {
#     Name = "foo"
#   }
# }

resource "aws_sagemaker_endpoint" "e" {
  name                 = "my-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.ec.name

  tags = {
    Name = "foo"
  }
}

resource "aws_sagemaker_device" "example" {
  device_fleet_name = aws_sagemaker_device_fleet.example.device_fleet_name

  device {
    device_name = "example"
  }
}

resource "aws_sagemaker_device_fleet" "example" {
  device_fleet_name = "example"
  role_arn          = aws_iam_role.role21.arn

  output_config {
    s3_output_location = "s3://${aws_s3_bucket.b.bucket}/prefix/"
  }
}


resource "aws_subnet" "main" {
  vpc_id     = "Default VPC"
  cidr_block = "172.31.0.0/16"

  tags = {
    Name = "Main"
  }
}
# resource "aws_default_vpc" "default" {
#   tags = {
#     Name = "Default VPC"
#   }
# }

resource "aws_s3_bucket" "b" {
  bucket = "likujh-sridevi"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}

# resource "aws_iam_instance_profile" "test_profile" {
#   name = "test_profile"
#   role = aws_iam_role.test_role.name
# }

# resource "aws_iam_role" "role" {
#   name = "test_role"
#   path = "/"

#   assume_role_policy = <<EOF
# {
#     "Version": "2012-10-17",
#     "Statement": [
#         {
#             "Action": "sts:AssumeRole",
#             "Principal": {
#                "Service": "ec2.amazonaws.com"
#             },
#             "Effect": "Allow",
#             "Sid": ""
#         }
#     ]
# }
# EOF
# }

resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id = "rule-1"

    # ... other transition/expiration actions ...

    status = "Enabled"
  }
}
resource "aws_s3_bucket" "example" {
  bucket = "example-bucket"
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.example.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}
 
