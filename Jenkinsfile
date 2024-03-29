pipeline {
    environment {
                AWSKEY = credentials("AWS_KEY")
                AWSSECRETKEY = credentials("AWS_SECRET_KEY")
                AWSREGION = credentials("AWS_REGION")
                EKSCLUSTERNAME = credentials("EKS_CLUSTER")
                NAMESPACE = credentials("NAMESPACE")
    } 
agent any
    stages {
        stage ('initialise Terraform') {
            steps {
                sh 'terraform init'
                sh 'terraform plan'
            }
        }
        stage ('create infrastructure on AWS ') {         
              
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
                sh 'aws configure set region $AWSREGION'
                sh 'aws configure set output text'
                //apply terraform files
                sh 'terraform apply -auto-approve'
                sh 'sleep 30'
            }
        }
    stage ('AWS elb') {
        steps {
            sh 'rm -Rf .aws'
            sh 'mkdir .aws'
            sh 'aws configure set aws_access_key_id $AWSKEY'
            sh 'aws configure set aws_secret_access_key $AWSSECRETKEY'
            sh 'aws configure set region $AWSREGION'
            sh 'aws configure set output text'
            sh 'aws eks --region $AWSREGION update-kubeconfig --name $EKSCLUSTERNAME'
            sh 'kubectl apply -f alb-sa.yaml'
            sh 'helm repo add eks https://aws.github.io/eks-charts'
            sh 'helm repo update eks'
            sh 'helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=$EKSCLUSTERNAME --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller'
            sh 'sed -i "s+name:.*replace.*+name: ${NAMESPACE}+g" shop-namespace.yaml'
            sh 'kubectl apply -f shop-namespace.yaml'
            sh 'kubectl apply -f shop-ingress.yaml -n $NAMESPACE'
        }
    }
    stage ('setup monitoring') {
        steps {
            sh 'rm -Rf .aws'
            sh 'mkdir .aws'
            sh 'aws configure set aws_access_key_id $AWSKEY'
            sh 'aws configure set aws_secret_access_key $AWSSECRETKEY'
            sh 'aws configure set region $AWSREGION'
            sh 'aws configure set output text'
            sh 'aws eks --region $AWSREGION update-kubeconfig --name $EKSCLUSTERNAME'
            //sh 'helm uninstall prometheus --namespace monitoring'
            sh 'helm repo add prometheus-community https://prometheus-community.github.io/helm-charts'
            sh 'helm repo update'
            sh 'kubectl apply -f mon-namespace.yaml'
            sh 'helm upgrade --install --timeout=15m prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --set grafana.service.type=NodePort --set promotheus.service.type=NodePort'
            sh 'kubectl apply -f mon-ingress.yaml'
        }
    }
    /*stage ('setup Velero') {
        steps {
            sh 'rm -Rf .aws'
            sh 'mkdir .aws'
            sh 'aws configure set aws_access_key_id $AWSKEY'
            sh 'aws configure set aws_secret_access_key $AWSSECRETKEY'
            sh 'aws configure set region $AWSREGION'
            sh 'aws configure set output text'
            sh 'aws eks --region $AWSREGION update-kubeconfig --name $EKSCLUSTERNAME'
            sh 'eksctl create iamserviceaccount --cluster=$EKSCLUSTERNAME --name=velero-server --namespace=velero --role-name=eks-velero-backup --role-only --attach-policy-arn=arn:aws:iam::700778905650:policy/TfEKSVeleroPolicy --approve'
            sh 'helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts'
            sh 'kubectl apply -f bak-namespace.yaml'
            sh 'helm upgrade --install --timeout=15m velero vmware-tanzu/velero --version 5.0.2 --namespace velero -f values.yaml'
        }
    }*/
    stage ('deploy all services') {
        // use sequentiel build steps
        steps {
            build job: "ms-frontend-ci-cd", wait: true

            // dbs
            build job: "ms-catalogue-db-ci-cd", wait: true
            build job: "ms-user-db-ci-cd", wait: true
            build job: "ms-carts-db-ci-cd", wait: true
            build job: "ms-order-db-ci-cd", wait: true

            // micro services
            build job: "ms-catalogue-ci-cd", wait: true
            build job: "ms-user-ci-cd", wait: true
            build job: "ms-carts-ci-cd", wait: true
            build job: "ms-orders-ci-cd", wait: true
            build job: "ms-payment-ci-cd", wait: true
            build job: "ms-queue-master-ci-cd", wait: true
            build job: "ms-rabbitmq-ci-cd", wait: true
            build job: "ms-shipping-ci-cd", wait: true
        }
    }
    stage ('destroy everything') {
        steps {
                // Create an Approval Button with a timeout of 15minutes.
                // this require a manuel validation in order to deploy on production environment
                timeout(time: 15, unit: "MINUTES") {
                            input message: 'Do you want to destroy the infrastructure?', ok: 'Yes'
                        }
                //config aws cli and auth with key id/secret
                sh 'rm -Rf .aws'
                sh 'mkdir .aws'
                sh 'aws configure set aws_access_key_id $AWSKEY'
                sh 'aws configure set aws_secret_access_key $AWSSECRETKEY'
                sh 'aws configure set region $AWSREGION'
                sh 'aws configure set output text'
                sh 'kubectl delete ingress monitoring-ingress -n monitoring'
                sh 'kubectl delete ingress sock-shop-ingress -n $NAMESPACE'
                //sh 'aws iam delete-policy --policy-arn arn:aws:iam::700778905650:policy/TfEKSVeleroPolicy'
                //destroy
                sh 'terraform destroy -auto-approve'
            }
        }
    }
} 
