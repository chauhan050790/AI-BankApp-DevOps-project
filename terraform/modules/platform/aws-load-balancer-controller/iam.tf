resource "aws_iam_role" "this" {
  name = "${var.project_name}-${var.environment}-alb-controller"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = local.common_tags
}

resource "aws_iam_policy" "this" {
  name        = "${var.project_name}-${var.environment}-alb-controller"
  description = "IAM policy for AWS Load Balancer Controller on ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.controller.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
