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
    }
}
