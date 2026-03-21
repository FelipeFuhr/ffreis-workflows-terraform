terraform {
  required_version = ">= 1.9.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "greeting" {
  content  = "Hello, ${var.name}!\n"
  filename = "${path.module}/greeting.txt"
}
