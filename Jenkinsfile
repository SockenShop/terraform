pipeline {
agent any
    stages {
        stage ('initialise Terraform') {
            steps {
                sh 'terraform init'
                sh 'terraform plan'
            }
        }
        stage ('create infrastructure on AWS ') {         
            environment {
                AWSKEY = credentials("AWS_KEY")
                AWSSECRETKEY = credentials("AWS_SECRET_KEY")
            }   
            steps {
                // Create an Approval Button with a timeout of 15minutes.
                // this require a manuel validation in order to deploy on production environment
                timeout(time: 15, unit: "MINUTES") {
                            input message: 'Do you want to provision in AWS ?', ok: 'Yes'
                        }
                //config aws cli and auth with key id/secret
                sh 'rm -Rf .aws'
                sh 'mkdir .aws'
                sh 'aws configure set aws_access_key_id $AWSKEY'
                sh 'aws configure set aws_secret_access_key $AWSSECRETKEY'
                sh 'aws configure set region eu-west-3'
                sh 'aws configure set output text'
                //apply terraform files
                sh 'terraform apply -auto-approve'
            }
        }
    stage ('AWS elb stuff') {
        environment {
                AWSKEY = credentials("AWS_KEY")
                AWSSECRETKEY = credentials("AWS_SECRET_KEY")
            }
        steps {
            sh 'rm -Rf .aws'
            sh 'mkdir .aws'
            sh 'aws configure set aws_access_key_id $AWSKEY'
            sh 'aws configure set aws_secret_access_key $AWSSECRETKEY'
            sh 'aws configure set region eu-west-3'
            sh 'aws configure set output text'
            sh 'aws eks --region eu-west-3 update-kubeconfig --name sock-shop-project'
            sh 'kubectl apply -f alb-sa.yaml'
            sh 'helm repo add eks https://aws.github.io/eks-charts'
            sh 'helm repo update eks'
            sh 'helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=sock-shop-project --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller'
            sh 'kubectl apply -f shop-namespace.yaml'
            sh 'kubectl apply -f shop-ingress.yaml'
        }
    }
    stage ('setup monitoring') {
        environment {
                AWSKEY = credentials("AWS_KEY")
                AWSSECRETKEY = credentials("AWS_SECRET_KEY")
            }
        steps {
            sh 'rm -Rf .aws'
            sh 'mkdir .aws'
            sh 'aws configure set aws_access_key_id $AWSKEY'
            sh 'aws configure set aws_secret_access_key $AWSSECRETKEY'
            sh 'aws configure set region eu-west-3'
            sh 'aws configure set output text'
            sh 'aws eks --region eu-west-3 update-kubeconfig --name sock-shop-project'
            sh 'helm repo add prometheus-community https://prometheus-community.github.io/helm-charts'
            sh 'helm repo update'
            sh 'kubectl apply -f mon-namespace.yaml'
            sh 'helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --set grafana.service.type=NodePort --set promotheus.service.type=NodePort'
            sh 'kubectl apply -f mon-ingress.yaml'
        }
    }
    stage ('destroy everything') {
        environment {
                AWSKEY = credentials("AWS_KEY")
                AWSSECRETKEY = credentials("AWS_SECRET_KEY")
            }
        steps {
                // Create an Approval Button with a timeout of 15minutes.
                // this require a manuel validation in order to deploy on production environment
                timeout(time: 15, unit: "MINUTES") {
                            input message: 'Do you want to the infrastructure?', ok: 'Yes'
                        }
                //config aws cli and auth with key id/secret
                sh 'rm -Rf .aws'
                sh 'mkdir .aws'
                sh 'aws configure set aws_access_key_id $AWSKEY'
                sh 'aws configure set aws_secret_access_key $AWSSECRETKEY'
                sh 'aws configure set region eu-west-3'
                sh 'aws configure set output text'
                //apply terraform files
                sh 'terraform destroy -auto-approve'
            }
        }
    }
} 
