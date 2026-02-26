resource "aws_db_subnet_group" "rds" {
  name       = "${var.env}-rds-subnet"
  subnet_ids = var.subnets

  tags = {
    Name = "${var.env}-rds-subnet"
  }
}

resource "aws_security_group" "rds" {
  name        = "${var.env}-rds-sg"
  description = "Allow ECS to access RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Postgres from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ecs_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "strapi" {
  identifier             = "${var.env}-strapi-db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp3"

  db_name                = "strapidb"
  username               = "strapi"
  password               = var.db_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.rds.name

  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true

  backup_retention_period = 7
  deletion_protection     = false

  tags = {
    Name = "${var.env}-strapi-db"
  }
}

output "db_endpoint" {
  value = aws_db_instance.strapi.endpoint
}