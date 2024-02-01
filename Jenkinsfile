pipeline {
agent any
    stages{
        stage ('initialise Terraform') {
            script {
                sh 'terraform init'
                sh 'terraform plan'
            }
        }
        stage ('create infrastructure on AWS ') {
            // Create an Approval Button with a timeout of 15minutes.
            // this require a manuel validation in order to deploy on production environment
            timeout(time: 15, unit: "MINUTES") {
                        input message: 'Do you want to provision in AWS ?', ok: 'Yes'
                    }
            script {
                sh 'terraform apply -auto-approve '
            }
        }
    } 
}