# Assume role policy
data "aws_iam_policy_document" "app1_eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oid_provider.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    # Condition to limit this role to be utilized by only the service account specified
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.oid_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:our-eks-sa-name"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.oid_provider.arn]
      type        = "Federated"
    }
  }
}

# Role for EKS to use to retrieve secret
resource "aws_iam_role" "app1_eks_role" {
  name               = "app1_eks_role"
  assume_role_policy = data.aws_iam_policy_document.app1_eks_assume_role_policy.json
}

# Policy to permit secret retrieval
resource "aws_iam_policy" "retrieve_secret" {
  name        = "app1_retrieve_secret"
  path        = "/"
  description = "IAM secret EKS"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ],
          "Resource" : [
            "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:app1*"
          ]
        }
      ]
    }
  )
}

output "eks_role_arn" {
  value = aws_iam_role.app1_eks_role.arn
}

# Link role to policy
resource "aws_iam_role_policy_attachment" "app1_eks_secret_retireve_attach" {
  role       = aws_iam_role.app1_eks_role.name
  policy_arn = aws_iam_policy.retrieve_secret.arn
}