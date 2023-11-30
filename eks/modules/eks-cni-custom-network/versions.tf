terraform {
  required_version = ">= 1.0"
  kubernetes = {
    source  = "hashicorp/kubernetes"
    version = ">= 2.10"
  }
}
