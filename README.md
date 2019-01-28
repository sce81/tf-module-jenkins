# tf-module-jenkins
Terraform Module for creating a Jenkins instance.

Contains persistent EBS volume to allow for upgrade of EC2 instance type and/or latest ubuntu 18.04 AMI releases. 

# Instructions for use
if creating a new EBS volume, the install will fail until the drive is formatted. To get around this, create as normal. Log into the instance and setup the drive. Afterwards, destroy the EC2 instance and the next deployment should work. 


*still to add, route53 entry for jenkins server*

*further parameterization*
