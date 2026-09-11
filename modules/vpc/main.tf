data "aws_availability_zones" "available" {
  state = "available"
}

# 1. Main VPC
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    { Name = "${var.environment}-vpc" }
  )
}

# 2. Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name                                           = "${var.environment}-public-subnet-${count.index + 1}"
      "kubernetes.io/role/elb"                       = "1"
      "kubernetes.io/cluster/${var.environment}-eks" = "shared"
    }
  )
}

# 3. Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(
    var.tags,
    {
      Name                                           = "${var.environment}-private-subnet-${count.index + 1}"
      "kubernetes.io/role/internal-elb"              = "1"
      "kubernetes.io/cluster/${var.environment}-eks" = "shared"
    }
  )
}

# 4. Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    { Name = "${var.environment}-igw" }
  )
}

# 5. Elastic IP for NAT
resource "aws_eip" "nat" {
  count  = var.enable_single_nat_gateway ? 1 : length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = merge(
    var.tags,
    { Name = "${var.environment}-nat-eip-${count.index + 1}" }
  )
}

# 6. NAT Gateway
resource "aws_nat_gateway" "this" {
  count         = var.enable_single_nat_gateway ? 1 : length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    { Name = "${var.environment}-nat-gw-${count.index + 1}" }
  )

  depends_on = [aws_internet_gateway.this]
}

# 7. Route Table & Associations - Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
    var.tags,
    { Name = "${var.environment}-public-rt" }
  )
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 8. Route Table & Associations - Private
resource "aws_route_table" "private" {
  count  = length(aws_subnet.private)
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.enable_single_nat_gateway ? aws_nat_gateway.this[0].id : aws_nat_gateway.this[count.index].id
  }

  tags = merge(
    var.tags,
    { Name = "${var.environment}-private-rt-${count.index + 1}" }
  )
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
