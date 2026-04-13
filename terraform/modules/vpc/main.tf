######################################################
# VPC Module
#
# 구성:
# 1. VPC                        - 인프라가 배치될 기본 네트워크
# 2. Internet Gateway           - Public Subnet의 인터넷 접근
# 3. Public Subnets             - ALB, NAT Gateway 배치
# 4. Private Subnets            - EKS Worker Node 배치
# 5. Private Data Subnets       - RDS, ElastiCache 배치
# 6. Elastic IPs                - NAT Gateway 공인 IP
# 7. NAT Gateways               - Private Subnet의 외부 통신
# 8. Public Route Table         - Internet Gateway 라우팅
# 9. Private Route Tables       - NAT Gateway 라우팅
# 10. Private Data Route Tables - Data Subnet 전용 라우팅
######################################################

locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

######################################################
# VPC
# - dev: 10.0.0.0/16
# - prod: 10.1.0.0/16
######################################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-vpc"
    }
  )
}

######################################################
# Internet Gateway
# - Public Subnet 리소스가 인터넷과 통신할 수 있도록 연결
# - ALB, NAT Gateway 등이 외부 인터넷과 통신할 때 사용
######################################################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-igw"
    }
  )
}

######################################################
# Public Subnets
# - ALB, NAT 배치
# - kubernetes.io/role/elb 태그를 통해 Public Load Balancer 생성에 사용
######################################################
resource "aws_subnet" "public" {
  for_each                = var.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name                     = "${local.name_prefix}-public-${each.key}"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

######################################################
# Private Subnets
# - EKS 워커 노드 배치
# - Internal ALB 및 Karpenter 노드 디스커버리에 사용
######################################################
resource "aws_subnet" "private" {
  for_each          = var.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.common_tags,
    {
      Name                                        = "${local.name_prefix}-private-${each.key}"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"           = "1"
      "karpenter.sh/discovery"                    = var.cluster_name
    }
  )
}

######################################################
# Private Data Subnets 
# - RDS, ElastiCache 배치
# - Application Subnet과 분리하여 보안 강화
######################################################
resource "aws_subnet" "private_data" {
  for_each          = var.private_data_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-private-data-${each.key}"
    }
  )
}

######################################################
# Elastic IP
# - NAT Gateway가 인터넷과 통신할 때 사용할 공인 IP 주소
# - 각 NAT Gateway마다 하나씩 할당
######################################################
resource "aws_eip" "nat" {
  for_each = var.nat_gateway_azs

  domain   = "vpc"

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-eip-${each.value}"
    }
  )
}

######################################################
# NAT Gateways
# - Private Subnet 리소스가 인터넷에 접근할 때 사용
# - 각 AZ에 1개씩, 고가용성 확보
######################################################
resource "aws_nat_gateway" "this" {
  for_each      = var.nat_gateway_azs

  allocation_id = aws_eip.nat[each.value].id
  subnet_id     = aws_subnet.public[each.value].id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-nat-${each.value}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

######################################################
# Public Route Table
# - Public Subnet 트래픽을 Internet Gateway로 라우팅
# - 인터넷과 직접 통신하는 리소스에 사용
######################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-rt-public"
    }
  )
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

######################################################
# Private Route Tables
# - Private Subnet 트래픽을 NAT Gateway로 라우팅
# - Private 리소스가 인터넷에 접근할 수 있도록 설정
######################################################
resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id   = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-rt-private-${each.key}"
    }
  )
}

resource "aws_route" "private_default" {
  for_each               = aws_route_table.private
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = try(
    aws_nat_gateway.this[each.key].id,
    aws_nat_gateway.this[keys(aws_nat_gateway.this)[0]].id
  )
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
######################################################
# Private Data Route Tables
# - Data Subnet 전용 라우팅 테이블
# - 외부 인터넷 연결 없이 VPC 내부 통신만 허용
######################################################
resource "aws_route_table" "private_data" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.common_tags,
    {
      Name = "${local.name_prefix}-rt-private-data"
    }
  )
}

resource "aws_route_table_association" "private_data" {
  for_each       = aws_subnet.private_data
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_data.id
}