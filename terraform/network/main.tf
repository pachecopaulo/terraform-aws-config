# https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                                               = "${var.vpc_name}-${var.environment}"
    Environment                                                        = var.environment
    "kubernetes.io/cluster/${var.eks_cluster_name}-${var.environment}" = "shared"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.eks_cluster_name}-${var.environment}-igw"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnets)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_internet_gateway.internet_gateway]

  tags = {
    Name        = "${var.eks_cluster_name}-${var.environment}-nat-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }
}

resource "aws_eip" "nat" {
  count = length(var.private_subnets)
  vpc   = true

  tags = {
    Name        = "${var.eks_cluster_name}-${var.environment}-eip-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  count             = length(var.private_subnets)

  tags = {
    Name                                                               = "${var.eks_cluster_name}-${var.environment}-private-subnet-${format("%03d", count.index + 1)}",
    Environment                                                        = var.environment,
    "kubernetes.io/cluster/${var.eks_cluster_name}-${var.environment}" = "shared"
    "kubernetes.io/role/internal-elb"                                  = "1"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name                                                               = "${var.eks_cluster_name}-${var.environment}-public-subnet-${format("%03d", count.index + 1)}",
    Environment                                                        = var.environment,
    "kubernetes.io/cluster/${var.eks_cluster_name}-${var.environment}" = "shared",
    "kubernetes.io/role/elb"                                           = "1"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.eks_cluster_name}-${var.environment}-routing-table-public"
    Environment = var.environment
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${var.eks_cluster_name}-${var.environment}-routing-table-private-${format("%03d", count.index + 1)}"
    Environment = var.environment
  }
}

resource "aws_route" "private" {
  count                  = length(compact(var.private_subnets))
  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
