pipeline {
agent any
    stages{
        stage ('initialise Terraform') {
            steps {
                sh 'terraform init'
                sh 'terraform plan'
            }
        }
        stage ('create infrastructure on AWS ') {
            // Create an Approval Button with a timeout of 15minutes.
            // this require a manuel validation in order to deploy on production environment
            steps {
                timeout(time: 15, unit: "MINUTES") {
                            input message: 'Do you want to provision in AWS ?', ok: 'Yes'
                        }
            }
            steps {
                //config aws cli and auth with key id/secret
                sh 'rm -Rf .aws'
                sh 'mkdir .aws'
                sh 'aws configure set aws_access_key_id $AWSKEY'
                sh 'aws configure set aws_secret_access_key $AWSSECRETKEY'
                sh 'aws configure set region eu-west-3'
                sh 'aws configure set output text'
                //apply terraform files
                sh 'terraform apply -auto-approve '
            }
        }
    } 
}