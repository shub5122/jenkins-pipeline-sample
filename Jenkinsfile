#!groovy
@Library('internal-pipeline-library@master') _

pipeline {
    agent none
    triggers {
        pollSCM('* * * * *')
    }
    options {
        // Only keep the 10 most recent builds
        buildDiscarder(logRotator(numToKeepStr:'10'))
    }
    parameters {
        // Parameters Needed for Share Libraries
        string(name: 'project_name', defaultValue: 'django-cms', description: 'What is this project called?')
        string(name: 'slack_channel', defaultValue: '#devops-testing', description: 'What channel should I send notifications to?')
        string(name: 'notification_email', defaultValue: 'admin@jenkins.local', description: 'What email address should I send notifications to?')
    }
    stages {
        stage('Start Notifications') {
            agent { label "fargate-default" }
            steps {
                // send build started notifications
                sendNotifications 'STARTED'
            }
        }
        stage('Unit Test') {
            agent { dockerfile true }
            steps {
                sh 'python --version'
                sh 'cd /django-web;python manage.py test'
            }
        }
        stage("Vulnerability Check") {
            agent {
                docker { 
                    image 'slopresto/jenkins-docker-agent:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock -u jenkins'
                }
            }
            steps {
                owaspScan()
            }
            post {
                success {
                    owaspPublish()
                }
            }
        }
        stage('Local Build Check') { 
            agent {
                docker { 
                    image 'slopresto/jenkins-docker-agent:latest'
                    args '-v /var/run/docker.sock:/var/run/docker.sock -u jenkins'
                }
            }
            steps {
                testDockerCompose "${project_name}"
            }
        }
        stage('Deploy') {
            agent { dockerfile true }
            steps {
                sh 'echo Deploying'
            }
        }

    }
    post {
        always {
            sendNotifications currentBuild.result
        }
    }
}