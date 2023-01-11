pipeline {
    agent any

    stages {
        stage('increment version') {
            steps{
                script {
                    // Enter app directory where all the related files are located.
                    dir("app") {
                        // Increment the minor version. Choices are: patch, minor or major
                        sh "npm version minor"

                        def jsonPackage = readJSON file: 'package.json'
                        def appVersion = jsonPackage.version
                        echo "version is incremented to ${appVersion}"

                        env.IMAGE_NAME = "$appVersion-$BUILD_NUMBER"
                        echo "Docker image name is ${env.IMAGE_NAME}"
                    }
                }
            }
        }

        stage('Run tests') {
            steps{
                script {
                    // Enter app directory where all the related files are located.
                    dir("app") {
                        sh "npm install"
                        sh "npm run test"
                    }
                }
            }
        }

        stage('Build and Push docker image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-credentials', usernameVariable: 'USER', passwordVariable: 'PWD')]){
                    sh "docker build -t arshashiri/demo-app:${IMAGE_NAME} ."
                    sh "echo ${PWD} | docker login -u ${USER} --password-stdin"
                    sh "docker push arshashiri/demo-app:${IMAGE_NAME}"
                }
            }
        }

        stage('commit version update to github') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'git-credentials', usernameVariable: 'USER', passwordVariable: 'PWD')]) {
                        // Configure git for the first time.
                        sh 'git config --global user.email "jenkins@example.com"'
                        sh 'git config --global user.name "jenkins"'

                        sh "git remote set-url origin git@github.com:ArshaShiri/DevOpsBootcampJenkinsAssignment.git"
                        sh 'git add .'
                        sh 'git commit -m "ci: version change"'
                        sh 'git push origin HEAD:main'
                    }
                }
            }
        }
    }
}
