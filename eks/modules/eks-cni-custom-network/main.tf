resource "kubectl_manifest" "this" {
  for_each  = var.secondary_subnets
  yaml_body = <<-YAML
  apiVersion: crd.k8s.amazonaws.com/v1alpha1
  kind: ENIConfig
  metadata: 
    name: ${each.key}
    namespace: default
  spec: 
    securityGroups: 
      - ${var.cluster_primary_security_group_id}
    subnet: ${each.value.id}
  YAML
}
