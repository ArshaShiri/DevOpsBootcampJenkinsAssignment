library identifier: 'jenkins-shared-library@main', retriever: modernSCM(
    [$class: 'GitSCMSource',
     remote: 'https://github.com/ArshaShiri/DevOpsBootcampJenkinsAssignmentSharedLib.git',
     credentialsId: 'git-credentials'
     ]
)

def gv

pipeline {
    agent any

    stages {

        stage('increment version') {
            steps{
                script {
                    incrementVersion()
                }
            }
        }

        stage('Run tests') {
            steps{
                script {
                    runTests()
                }
            }
        }

        stage('Build and Push docker image') {
            steps {
                script {
                    buildAndPushDockerImage()
                }
            }
        }

        stage('commit version update to github') {
            steps {
                script {
                    commitVersionChangeToGit()
                }
            }
        }
    }
}
