locals {

  kubeconfig = <<KUBECONFIG

---
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.eks_cluster.endpoint}
    certificate-authority-data: ${aws_eks_cluster.eks_cluster.certificate_authority.0.data}
  name: ${aws_eks_cluster.eks_cluster.arn}
contexts:
- context:
    cluster: ${aws_eks_cluster.eks_cluster.arn}
    user: ${aws_eks_cluster.eks_cluster.arn}
  name: ${aws_eks_cluster.eks_cluster.arn}
current-context: ${aws_eks_cluster.eks_cluster.arn}
kind: Config
preferences: {}
users:
- name: ${aws_eks_cluster.eks_cluster.arn}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws
      args:
        - --region
        - ${var.region}
        - eks
        - get-token
        - --cluster-name
        - ${var.cluster_name}
      env:
      - name: AWS_PROFILE
        value: ${var.aws_profile}
KUBECONFIG
}
