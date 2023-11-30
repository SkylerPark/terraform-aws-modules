resource "kubectl_manifest" "this" {
  for_each  = { for subnet in var.var.secondary_subnets : subnet.availability_zone => subnet }
  yaml_body = <<-YAML
  apiVersion: crd.k8s.amazonaws.com/v1alpha1
  kind: ENIConfig
  metadata: 
    name: ${each.value.availability_zone}
  spec: 
    securityGroups: 
      - ${var.cluster_primary_security_group_id}
    subnet: ${each.value.id}
  YAML
}
