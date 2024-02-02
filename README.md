# terraform-repo
- deployment of AWS infrastructure as code with terraform
- will create EKS cluster, roles and policies
## usage 
### automated
webhook triggers jenkins pipeline (see Jenkinsfile) on code commit/push
### manual
- aws configure
- clone repo
- terraform init
- terraform plan
- terraform apply