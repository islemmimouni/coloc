# Chaîne de confiance : Internet -> ALB -> application -> base de données
resource "aws_security_group" "alb" {
  name_prefix = "${var.name}-alb-"
  description = "HTTP/HTTPS depuis Internet"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name}-sg-alb" }
}

resource "aws_security_group" "app" {
  name_prefix = "${var.name}-app-"
  description = "Application : trafic uniquement depuis ALB"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.name}-sg-app" }
}

resource "aws_security_group" "db" {
  name_prefix = "${var.name}-db-"
  description = "MySQL uniquement depuis application"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  tags = { Name = "${var.name}-sg-db" }
}
