# terraform-repo
- deployment of AWS infrastructure as code with terraform
- will create EKS cluster, roles and policies
## usage 
### automated
webhook triggers jenkins pipeline (see Jenkinsfile) on code commit/push
### manual
- aws cli (configure with your access key and region)
- clone repo
- terraform init
- terraform plan
- terraform apply
- apply manifestfiles with kubectl
