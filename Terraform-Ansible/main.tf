local {
vpc_id = "vpc-29a31654"
subnet_id = "subnet-7547de13"
key_name = "donsamosa"
ssh_user = "ec2-user"
private_key_path = "/opt/donsamosa.pem"
}

provider "aws" {
region = "us-east-1"
}

resource "aws_security_group" "awssecurity" {
name = "Terraform_access"
vpc_id = local.vpc_id
ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"] 
}
ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"] 
}
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"] 
}
}

resource "aws_instance" "AnsiTerra" {
ami = "ami-0dc2d3e4c0f9ebd18"
subnet_id = local.subnet_id
instance_type = "t2.micro"
associate_public_ip_address = "true"
security_groups = [aws_security_group.awssecurity.id]
key_name = local.key_name

provisioner "remote-exec" {
inline = ["echo 'wait for the ssh'"]

connection {
type = "ssh"
user = local.ssh_user
private_key = file(local.private_key_path)
host = aws_instance.AnsiTerra.public_ip
}
}
provisioner "local-exec" {
command = "ansible-playbook -i ${aws_instance.AnsiTerra.public_ip}, --private-key ${local.private_key_path} nginx.yaml"
}
}
output "publicip" {
value = aws_instance.AnsiTerra.public_ip
}