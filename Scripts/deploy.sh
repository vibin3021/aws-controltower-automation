#!/bin/bash
mkdir aws-asslandingzone
cd aws-asslandingzone
terraform init
terraform validate
terraform plan
terraform apply
