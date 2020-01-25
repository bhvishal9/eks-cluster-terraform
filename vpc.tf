resource "aws_vpc" "eks_cluster_vpc" {
  cidr_block = var.vpc_cidr

  tags = map(
    "Name", "eks-cluster-vpc",
    "kubernetes.io/cluster/${var.cluster_name}", "shared",
  )
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "eks_cluster_subnet" {
  count             = var.subnet_count
  availability_zone = data.aws_availability_zones.available.names[count.index]

  cidr_block = cidrsubnet(var.vpc_cidr,
    var.vpc_cidr_extension_bits,
  var.vpc_cidr_extension_start + count.index)

  vpc_id = aws_vpc.eks_cluster_vpc.id

  tags = map(
    "Name", "${var.cluster_name}-${data.aws_availability_zones.available.names[count.index]}",
    "kubernetes.io/cluster/${var.cluster_name}", "shared",
  )
}

resource "aws_internet_gateway" "eks_cluster_ig" {
  vpc_id = aws_vpc.eks_cluster_vpc.id

  tags = {
    Name = "toptal-cluster-ig"
  }
}

resource "aws_route_table" "eks_cluster_rt" {
  vpc_id = aws_vpc.eks_cluster_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_cluster_ig.id
  }
}

resource "aws_route_table_association" "eks_cluster_rt" {
  count = var.subnet_count

  subnet_id      = aws_subnet.eks_cluster_subnet.*.id[count.index]
  route_table_id = aws_route_table.eks_cluster_rt.id
}
