bucket         = "cloudwave-terraform-state"
key            = "prod/terraform.tfstate"
region         = "ap-northeast-2"
dynamodb_table = "cloudwave-terraform-lock"
encrypt        = true