variable "env" {}
variable "subnets" {}
variable "vpc_id" {}
variable "ecs_sg" {}

variable "db_password" {
  sensitive = true
}