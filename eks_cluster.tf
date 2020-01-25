resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-master"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks_cluster_aws_cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_aws_service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_security_group" "eks_cluster_master" {
  name        = "${var.cluster_name}-master"
  description = "Master ingress/egress"
  vpc_id      = aws_vpc.eks_cluster_vpc.id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Kubernetes API access"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.cluster_version

  vpc_config {
    security_group_ids = [aws_security_group.eks_cluster_master.id]
    subnet_ids         = aws_subnet.eks_cluster_subnet.*.id
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_aws_cluster,
    aws_iam_role_policy_attachment.eks_cluster_aws_service
  ]

  provisioner "local-exec" {
    command = <<EOT
    until curl -k -s ${aws_eks_cluster.eks_cluster.endpoint}/healthz >/dev/null; do sleep 4; done
  EOT
  }
}
