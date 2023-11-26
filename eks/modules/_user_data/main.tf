locals {
  int_linux_default_user_data = var.enable_bootstrap_user_data ? base64encode(templatefile(
    "${path.module}/../../templates/linux_user_data.tpl",
    {
      enable_bootstrap_user_data = var.enable_bootstrap_user_data
      cluster_name               = var.cluster_name
      cluster_endpoint           = var.cluster_endpoint
      cluster_auth_base64        = var.cluster_auth_base64
      cluster_service_ipv4_cidr  = var.cluster_service_ipv4_cidr != null ? var.cluster_service_ipv4_cidr : ""
      bootstrap_extra_args       = var.bootstrap_extra_args
      pre_bootstrap_user_data    = var.pre_bootstrap_user_data
      post_bootstrap_user_data   = var.post_bootstrap_user_data
    }
  )) : ""
}
