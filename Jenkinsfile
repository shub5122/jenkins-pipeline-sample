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
        string(name: 'slack_channel', defaultValue: '#devops-testing', description: 'What channel should I send notifications to?')
        string(name: 'notification_email', defaultValue: 'admin@jenkins.local', description: 'What email address should I send notifications to?')
        // Parameters Needed for defining custom Docker Agent image
        string(name: 'docker_agent_image', defaultValue: 'slopresto/jenkins-docker-agent:latest', description: 'What is the docker agent image that I should use?')
    }
    stages {
        stage('Start Notifications') {
            agent { dockerfile true }
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
                    image "${docker_agent_image}"
                    args '-v /var/run/docker.sock:/var/run/docker.sock -u jenkins'
                }
            }
            steps {
                owasp_check()
            }
            post {
                success {
                    publish_owasp_reports()
                }
            }
        }
        stage('Local Build Check') { 
            agent {
                docker { 
                    image "${docker_agent_image}"
                    args '-v /var/run/docker.sock:/var/run/docker.sock -u jenkins'
                }
            }
            steps {
                test_docker_compose('django-cms')
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