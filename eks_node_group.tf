resource "aws_iam_role" "eks_cluster_node_role" {
  name = "${var.cluster_name}-node"

  assume_role_policy = data.aws_iam_policy_document.eks_cluster_node_role.json
}

data "aws_iam_policy_document" "eks_cluster_node_role" {
  statement {
    sid = "EKSAccess"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role_policy_attachment" "eks_node_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_cluster_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_cluster_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_ecr_read" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_cluster_node_role.name
}

resource "aws_eks_node_group" "eks_cluster_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_cluster_node_role.arn
  subnet_ids      = aws_subnet.eks_cluster_subnet.*.id
  instance_types  = [var.node_instance_size]

  scaling_config {
    desired_size = var.node_count
    max_size     = var.node_count
    min_size     = var.node_count
  }

  depends_on = [
    "aws_iam_role_policy_attachment.eks_node_worker_node_policy",
    "aws_iam_role_policy_attachment.eks_node_cni_policy",
    "aws_iam_role_policy_attachment.eks_node_ecr_read",
  ]
}
