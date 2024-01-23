module "policy" {
  source      = "../../../iam/modules/iam-policy"
  name_prefix = "KarpenterControllerPolicy_"
  path        = "/"
  description = ""
  policy = jsonencode(
    {
      "Statement" : [
        {
          "Action" : [
            "ssm:GetParameter",
            "iam:PassRole",
            "ec2:DescribeImages",
            "ec2:RunInstances",
            "ec2:DescribeSubnets",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeLaunchTemplates",
            "ec2:DescribeInstances",
            "ec2:DescribeInstanceTypes",
            "ec2:DescribeInstanceTypeOfferings",
            "ec2:DescribeAvailabilityZones",
            "ec2:DeleteLaunchTemplate",
            "ec2:CreateTags",
            "ec2:CreateLaunchTemplate",
            "ec2:CreateFleet",
            "ec2:DescribeSpotPriceHistory",
            "pricing:GetProducts"
          ],
          "Effect" : "Allow",
          "Resource" : "*",
          "Sid" : "Karpenter"
        },
        {
          "Action" : "ec2:TerminateInstances",
          "Condition" : {
            "StringLike" : {
              "ec2:ResourceTag/Name" : "*karpenter*"
            }
          },
          "Effect" : "Allow",
          "Resource" : "*",
          "Sid" : "ConditionalEC2Termination"
        }
      ],
      "Version" : "2012-10-17"
    }
  )
}

data "aws_iam_policy_document" "custom_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["${var.openid_connect_arn}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.openid_connect_url, "https://", "")}:sub"

      values = ["system:serviceaccount:karpenter:karpenter"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(var.openid_connect_url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    effect = "Allow"
  }
}

module "role" {
  source                          = "../../../iam/modules/iam-assumable-role"
  create_role                     = true
  role_name_prefix                = "KarpenterControllerRole_"
  create_custom_role_trust_policy = true

  custom_role_policy_arns = [
    module.policy.arn
  ]

  custom_role_trust_policy = data.aws_iam_policy_document.custom_trust_policy.json
}

resource "helm_release" "this" {
  name             = var.name
  repository       = var.repository
  chart            = var.chart
  namespace        = var.namespace
  create_namespace = true

  dynamic "set" {
    for_each = {
      "clusterName"                                               = "${var.cluster_name}"
      "clusterEndpoint"                                           = "${var.cluster_endpoint}"
      "aws.defaultInstanceProfile"                                = "${var.karpenter_profile}"
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = "${module.role.iam_role_arn}"
    }
    content {
      name  = set.key
      value = set.value
    }
  }
}

resource "kubectl_manifest" "provisioner" {
  yaml_body = templatefile(
    "${path.module}/karpenter-provisioner.yaml.tmpl",
    {
      requirements = var.karpenter_provisioner_requirements
    }
  )
  depends_on = [
    helm_release.this
  ]
}

resource "kubectl_manifest" "aws_node_template" {
  yaml_body = <<-YAML
  apiVersion: karpenter.k8s.aws/v1alpha1
  kind: AWSNodeTemplate
  metadata:
    name: default
  spec:
    subnetSelector:
      karpenter.sh/discovery: "${var.cluster_name}"
    securityGroupSelector:
      karpenter.sh/discovery: "${var.cluster_name}"
    amiFamily: AL2
    blockDeviceMappings:
      - deviceName: /dev/xvda
        ebs:
          volumeSize: 100G
          volumeType: gp3
          iops: 3000
          throughput: 125
          deleteOnTermination: true
    tags:
      Name: "${var.cluster_name}-node"
  YAML
  depends_on = [
    kubectl_manifest.provisioner
  ]
}
