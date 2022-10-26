variable "vpc_id" {
  type = string
}
## private subnets for magnum-bank-hml

variable "cluster_version" {
  default = "1.23"
}

variable "node_group_name" {
 
}

variable "nodes_instance_sizes" {
  default = [
    "t3a.medium",
    "t3.large",
    "t3a.large"
  ]
}

variable "subnet_ids" {
  
}


variable "env" {
  
}


variable "cluster_name" {
  
}


variable "key_name" {
  
}
