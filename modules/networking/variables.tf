variable "vpc_cidr_block" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "public_subnets" {
  type = list(any)
}

variable "private_subnets" {
  type = list(any)
}

variable "customer_group" {
  type = string
}

variable "env" {
  type = string
}
