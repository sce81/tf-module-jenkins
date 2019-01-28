output "ami_id" {
  value = "aws_ami.ubuntu.image_id"
}

output "ami_name" {
  value = "aws_ami.ubuntu.name"
}

output "ami_creation_date" {
  value = "aws_ami.ubuntu.creation_date"
}

output "ami_descripton" {
  value = "aws_ami.ubuntu.creation_date"
}

output "instance_id" {
  value = "aws_instance.jenkins.id"
}

output "instance_private_ip" {
  value = "aws_instance.jenkins.private_ip"
}

output "instance_arn" {
  value = "aws_instance.jenkins.arn"
}

#output "instance_vpc_security_group_ids" {
#  value = "aws_instance.jenkins.vpc_security_group_ids"
#}