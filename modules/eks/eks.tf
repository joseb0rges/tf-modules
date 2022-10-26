resource "aws_eks_cluster" "eks-magnum-bank-cluster" {
  name                      = var.cluster_name
  role_arn                  = aws_iam_role.eks-magnum-bank-cluster.arn
  version                   = var.cluster_version
  enabled_cluster_log_types = ["api", "audit"]
  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = false
    subnet_ids              = var.subnet_ids

    security_group_ids = [aws_security_group.cluster.id]

  }

  tags = {
    "Environment"      = var.env
    "Application_ID"   = "eks"
    "Application_Role" = "Abriga Microservicos do D-Influencers"
    "Team"             = "Magnum-Bank"
    "Customer_Group"   = "mb"
    "RESOURCE"         = "KUBERNETES"
    "CUSTOMER"         = "MAGNUM-BANK-${var.env}"
    "BU"               = "MAGNUM-BANK-${var.env}"
  }

}

resource "aws_eks_node_group" "magnum-bank" {
  node_group_name = var.node_group_name
  cluster_name    = var.cluster_name
  node_role_arn   = aws_iam_role.node-magnum-bank.arn
  instance_types  = var.nodes_instance_sizes
  ami_type        = "AL2_x86_64"
  capacity_type   = "SPOT"
  subnet_ids      = var.subnet_ids

  launch_template {
    id      = aws_launch_template.lc-magnum-bank.id
    version = aws_launch_template.lc-magnum-bank.latest_version
  }

  scaling_config {
    desired_size = 1
    max_size     = 10
    min_size     = 1
  }

  # tags = {
  #   key                 = "Name"
  #   value               = "asg-magnum-bank-${var.env}-nodes"
  #   Environment = var.env
  #   Application_ID = "eks"
  #   Application_Role = "Abriga Microservicos do D-Influencers"
  #   Team  =  "Magnum-Bank"
  #   Customer_Group = "mb"
  #   RESOURCE = "KUBERNETES"
  #   CUSTOMER = "MAGNUM-BANK-${var.env}"
  #   BU = "MAGNUM-BANK-${var.env}"
  # }

  depends_on = [
    aws_launch_template.lc-magnum-bank,
    aws_eks_cluster.eks-magnum-bank-cluster

  ]

}


resource "aws_launch_template" "lc-magnum-bank" {
  name                   = "lc-magnum-bank-${var.env}"
  update_default_version = true
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
      encrypted   = true
    }
  }
  credit_specification {
    cpu_credits = "standard"
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      "Name"             = "magnum-bank-${var.env}-nodes"
      "Environment"      = "${var.env}"
      "Application_ID"   = "eks"
      "Application_Role" = "Abriga Microservicos do D-Influencers"
      "Team"             = "Magnum-Bank"
      "Customer_Group"   = "mb"
      "RESOURCE"         = "KUBERNETES"
      "CUSTOMER"         = "MAGNUM-BANK-${var.env}"
      "BU"               = "MAGNUM-BANK-${var.env}"
    }
  }
  tag_specifications {
    resource_type = "volume"

    tags = {
      "Name"             = "vol-magnum-bank-${var.env}"
      "Environment"      = "${var.env}"
      "Application_ID"   = "eks"
      "Application_Role" = "Abriga Microservicos do D-Influencers"
      "Team"             = "Magnum-Bank"
      "Customer_Group"   = "mb"
      "RESOURCE"         = "KUBERNETES"
      "CUSTOMER"         = "MAGNUM-BANK-${var.env}"
      "BU"               = "MAGNUM-BANK-${var.env}"
    }
  }

  ebs_optimized = true
  # AMI generated with packer (is private)
  key_name = var.key_name
  network_interfaces {
    associate_public_ip_address = false
  }

  tags = {
    "Name"             = "lc-magnum-bank-${var.env}"
    "Environment"      = "${var.env}"
    "Application_ID"   = "eks"
    "Application_Role" = "Abriga Microservicos do D-Influencers"
    "Team"             = "Magnum-Bank"
    "Customer_Group"   = "mb"
    "RESOURCE"         = "KUBERNETES"
    "CUSTOMER"         = "MAGNUM-BANK-${var.env}"
    "BU"               = "MAGNUM-BANK-${var.env}"

  }

}


resource "aws_security_group" "control_plane_cluster_sg" {
  name        = format("%s-control-plane-sg", var.cluster_name)
  description = "rule for allow access in the api-server from internal magnum-bank-${var.env} environment"
  vpc_id      = var.vpc_id
  egress {
    from_port = 0
    to_port   = 0

    protocol    = "-1"
    cidr_blocks = ["10.10.64.0/19", "10.210.0.0/17", "172.17.0.0/16", "10.1.0.0/16", "10.100.0.0/19", "172.16.0.0/20", "172.18.0.0/20", "172.30.0.0/20"]
  }

  tags = {
    Name               = format("%s-control-plane-sg", var.cluster_name)
    "Environment"      = "${var.env}"
    "Application_ID"   = "eks"
    "Application_Role" = "Abriga Microservicos do D-Influencers"
    "Team"             = "Magnum-Bank"
    "Customer_Group"   = "mb"
    "RESOURCE"         = "KUBERNETES"
    "CUSTOMER"         = "MAGNUM-BANK-${var.env}"
    "BU"               = "MAGNUM-BANK-${var.env}"

  }

}

resource "aws_security_group_rule" "internal_access_api_server_vpc_cluster" {
  cidr_blocks = ["10.10.64.0/19", "10.210.0.0/17", "172.17.0.0/16", "10.1.0.0/16", "10.100.0.0/19", "172.16.0.0/20", "172.18.0.0/20", "172.30.0.0/20"]
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  description = "rule for allow access in the api-server from internal nodes_vpc_${var.env} environment"

  security_group_id = aws_security_group.control_plane_cluster_sg.id
  type              = "ingress"

}
