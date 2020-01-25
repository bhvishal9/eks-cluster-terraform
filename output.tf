resource "local_file" "eks_kubeconfig" {
  content  = local.kubeconfig
  filename = "${path.root}/kubeconfig"
}
