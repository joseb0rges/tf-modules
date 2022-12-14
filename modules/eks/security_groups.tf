resource "aws_security_group" "internal_ssh" {
  name   = "${var.cluster_name}/internal_ssh"
  vpc_id = var.vpc_id
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "172.16.0.0/20",
    ]
  }
  tags = {
    "Name" = "${var.cluster_name}/internal_ssh"
  }
}

resource "aws_security_group" "cluster" {
  name_prefix = var.cluster_name
  description = "EKS cluster security group."
  vpc_id      = var.vpc_id
  tags = {
    "Name" = "${var.cluster_name}-eks_cluster_sg"
  }
}

resource "aws_security_group_rule" "vpn_cluster" {
  security_group_id = aws_security_group.cluster.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["10.210.0.0/17"]
  description       = "Sciensa VPN Access"
}

resource "aws_security_group_rule" "cluster_egress_internet" {
  description       = "Allow cluster egress access to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.cluster.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group" "workers" {
  name_prefix = var.cluster_name
  description = "Security group for all nodes in the cluster."
  vpc_id      = var.vpc_id
  tags =  {
    "Name"                                      = "${var.cluster_name}-eks_worker_sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "vpn_workers" {
  security_group_id = aws_security_group.workers.id
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["10.210.0.0/17"]
  description       = "Sciensa VPN Access"
}

resource "aws_security_group_rule" "cluster_https_worker_ingress" {
  description              = "Allow pods to communicate with the EKS cluster API."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.workers.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_egress_internet" {
  description       = "Allow nodes all egress to the Internet."
  protocol          = "-1"
  security_group_id = aws_security_group.workers.id
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  type              = "egress"
}

resource "aws_security_group_rule" "workers_ingress_self" {
  description              = "Allow node to communicate with each other."
  protocol                 = "-1"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.workers.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster" {
  description              = "Allow workers pods to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 1025
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_kubelet" {
  description              = "Allow workers Kubelets to receive communication from the cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 10250
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_https" {
  description              = "Allow pods running extension API servers on port 443 to receive communication from cluster control plane."
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 443
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "workers_ingress_cluster_primary" {
  description              = "Allow pods running on workers to receive communication from cluster primary security group."
  protocol                 = "all"
  security_group_id        = aws_security_group.workers.id
  source_security_group_id = aws_security_group.cluster.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster_primary_ingress_workers" {
  description              = "Allow pods running on workers to send communication to cluster primary security group."
  protocol                 = "all"
  security_group_id        = aws_security_group.cluster.id
  source_security_group_id = aws_security_group.workers.id
  from_port                = 0
  to_port                  = 65535
  type                     = "ingress"
}
