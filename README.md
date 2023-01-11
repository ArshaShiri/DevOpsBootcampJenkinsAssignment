#### This project is for the Devops bootcamp assignment for Jenkins

## EXERCISE 1: Dockerize your NodeJS App
Configure your application to be built as a Docker image.

* Dockerize your NodeJS app

**Solution:**

Added a docker file based on [this](https://hub.docker.com/_/node) image.

## EXERCISE 2: Create a full pipeline for your NodeJS App

You want the following steps to be included in your pipeline:

* Increment version

The application's version and docker image version should be incremented.

* Run tests

You want to test the code, to be sure to deploy only working code. When tests fail, the pipeline should abort.

* Build docker image with incremented version
* Push to Docker repository
* Commit to Git

The application version increment must be committed and pushed to a remote Git repository.

**Solution:**

#### Creating Server:


The following droplet is created:

![image](https://user-images.githubusercontent.com/18715119/211541922-3b364fe6-643c-47a3-8425-5c0eec5a1d68.png)

#### Installing Jenkins:

After installing docker, we run the following command to install Jenkins:

    docker run -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins

We also add the following firewall rules:

![image](https://user-images.githubusercontent.com/18715119/211543692-626baadd-11e7-45bf-ba47-f4845b77691e.png)

Jenkins can be accessed:

![image](https://user-images.githubusercontent.com/18715119/211543971-b528c439-bd9e-422d-814f-7c3280c4fca9.png)

We can retrieve the password from the mounted volume by:

    root@Jenkins:~# docker volume ls
    
    DRIVER    VOLUME NAME
    local     jenkins_home
    
    root@Jenkins:~# docker inspect jenkins_home
    
    [
        {
            "CreatedAt": "2023-01-10T11:46:35Z",
            "Driver": "local",
            "Labels": null,
            "Mountpoint": "/var/lib/docker/volumes/jenkins_home/_data",
            "Name": "jenkins_home",
            "Options": null,
            "Scope": "local"
        }
    ]
    
    cat /var/lib/docker/volumes/jenkins_home/_data/secrets/initialAdminPassword

    

After inserting the password we can install the suggested plugins and create a username and password.

![image](https://user-images.githubusercontent.com/18715119/211547449-ef7ac942-d783-4431-a598-0ac0786d2cb8.png)


#### Installing npm & node & docker on the running container:

    docker exec -u 0 -it {container-id} bash
    apt install curl
    curl -fsSL https://deb.nodesource.com/setup_19.x -o nodesource_setup.sh
    bash nodesource_setup.sh
    apt install nodejs

    curl https://get.docker.com > dockerinstall && chmod 777 dockerinstall && ./dockerinstall
    chmod 666 /var/run/docker.sock


#### Creating the pipeline:

A pipeline named **Node** is created.

![image](https://user-images.githubusercontent.com/18715119/211551348-698a5764-b0a9-4deb-a490-ad3ce2127014.png)

After creating a dummy Jenkinsfile the build can succeed:

    pipeline {
        agent any

        stages {
            stage('dummy') {
                steps{
                    echo 'dummy step to test the pipeline...'
                }
            }
        }
    }
    
![image](https://user-images.githubusercontent.com/18715119/211551751-9d95518b-baa5-4399-955b-765c55305a07.png)


The `Run tests` stage is added to the Jenkinsfile instead of the dummy stage:

    pipeline {
        agent any

        stages {
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


The tests can run successfully:

![image](https://user-images.githubusercontent.com/18715119/211553251-e73f89a8-ad2a-4ee6-b228-babca4b5a4d3.png)

In order to increase the version and use it in other steps, we need to be able to read the `package.json` file after version increment. To read json files, we have to install `Pipeline Utility Steps` plugin on Jenkins. After installation, we update the Jenkinsfile with `increment version` stage.

The update Jenkisfiles is: 

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

The build is successful:

![image](https://user-images.githubusercontent.com/18715119/211569444-73e5ecb9-342f-47fc-999c-90ca42854d98.png)

After adding the docker credentials we proceed to add the step for building docker image.

![image](https://user-images.githubusercontent.com/18715119/211571856-26ef9cf3-de21-4156-acf9-536c9dcfce9c.png)

The updated Jenkinsfile is:

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
        }
    }


The build output is:

    Started by user arsha
    Replayed #34
    [Pipeline] Start of Pipeline
    [Pipeline] node
    Running on Jenkins in /var/jenkins_home/workspace/Node
    [Pipeline] {
    [Pipeline] stage
    [Pipeline] { (Declarative: Checkout SCM)
    [Pipeline] checkout
    Selected Git installation does not exist. Using Default
    The recommended git tool is: NONE
    using credential git-credentials
     > git rev-parse --resolve-git-dir /var/jenkins_home/workspace/Node/.git # timeout=10
    Fetching changes from the remote Git repository
     > git config remote.origin.url https://github.com/ArshaShiri/DevOpsBootcampJenkinsAssignment.git # timeout=10
    Fetching upstream changes from https://github.com/ArshaShiri/DevOpsBootcampJenkinsAssignment.git
     > git --version # timeout=10
     > git --version # 'git version 2.30.2'
    using GIT_ASKPASS to set credentials 
     > git fetch --tags --force --progress -- https://github.com/ArshaShiri/DevOpsBootcampJenkinsAssignment.git +refs/heads/*:refs/remotes/origin/* # timeout=10
     > git rev-parse refs/remotes/origin/main^{commit} # timeout=10
    Checking out Revision ce0eaabc9d6e7e804b7fcc168ec815ac2ddda426 (refs/remotes/origin/main)
     > git config core.sparsecheckout # timeout=10
     > git checkout -f ce0eaabc9d6e7e804b7fcc168ec815ac2ddda426 # timeout=10
    Commit message: "Updated Readme with docker credentials explanations."
     > git rev-list --no-walk ce0eaabc9d6e7e804b7fcc168ec815ac2ddda426 # timeout=10
    [Pipeline] }
    [Pipeline] // stage
    [Pipeline] withEnv
    [Pipeline] {
    [Pipeline] stage
    [Pipeline] { (increment version)
    [Pipeline] script
    [Pipeline] {
    [Pipeline] dir
    Running in /var/jenkins_home/workspace/Node/app
    [Pipeline] {
    [Pipeline] sh
    + npm version minor
    v1.1.0
    [Pipeline] readJSON
    [Pipeline] echo
    version is incremented to 1.1.0
    [Pipeline] echo
    Docker image name is 1.1.0-35
    [Pipeline] }
    [Pipeline] // dir
    [Pipeline] }
    [Pipeline] // script
    [Pipeline] }
    [Pipeline] // stage
    [Pipeline] stage
    [Pipeline] { (Run tests)
    [Pipeline] script
    [Pipeline] {
    [Pipeline] dir
    Running in /var/jenkins_home/workspace/Node/app
    [Pipeline] {
    [Pipeline] sh
    + npm install

    up to date, audited 555 packages in 2s

    24 packages are looking for funding
      run `npm fund` for details

    11 vulnerabilities (1 low, 2 moderate, 7 high, 1 critical)

    To address issues that do not require attention, run:
      npm audit fix

    To address all issues, run:
      npm audit fix --force

    Run `npm audit` for details.
    [Pipeline] sh
    + npm run test

    > bootcamp-node-project@1.1.0 test
    > jest

    Browserslist: caniuse-lite is outdated. Please run:
    npx browserslist@latest --update-db

    Why you should do it regularly:
    https://github.com/browserslist/browserslist#browsers-data-updating
    PASS ./server.test.js
      ✓ main index.html file exists (3 ms)

    Test Suites: 1 passed, 1 total
    Tests:       1 passed, 1 total
    Snapshots:   0 total
    Time:        1.479 s
    Ran all test suites.
    [Pipeline] }
    [Pipeline] // dir
    [Pipeline] }
    [Pipeline] // script
    [Pipeline] }
    [Pipeline] // stage
    [Pipeline] stage
    [Pipeline] { (Build and Push docker image)
    [Pipeline] withCredentials
    Masking supported pattern matches of $USER or $PWD
    [Pipeline] {
    [Pipeline] sh
    Warning: A secret was passed to "sh" using Groovy String interpolation, which is insecure.
             Affected argument(s) used the following variable(s): [USER]
             See https://jenkins.io/redirect/groovy-string-interpolation for details.
    + docker build -t ****/demo-app:1.1.0-35 .
    Sending build context to Docker daemon  44.02MB

    Step 1/8 : FROM node:19-alpine
     ---> 17299c0421ee
    Step 2/8 : RUN mkdir -p /usr/app
     ---> Using cache
     ---> 3c54720a18a1
    Step 3/8 : COPY app/. /usr/app/
     ---> Using cache
     ---> 786410fd6595
    Step 4/8 : WORKDIR /usr/app
     ---> Using cache
     ---> 2c57d01ae935
    Step 5/8 : RUN ls
     ---> Using cache
     ---> f4135ebfa1f4
    Step 6/8 : EXPOSE 3000
     ---> Using cache
     ---> 6833e67012dc
    Step 7/8 : RUN npm install
     ---> Using cache
     ---> 2100a0990a37
    Step 8/8 : CMD ["node", "server.js"]
     ---> Using cache
     ---> 4ed604c1c839
    Successfully built 4ed604c1c839
    Successfully tagged ****/demo-app:1.1.0-35
    [Pipeline] sh
    Warning: A secret was passed to "sh" using Groovy String interpolation, which is insecure.
             Affected argument(s) used the following variable(s): [USER, PWD]
             See https://jenkins.io/redirect/groovy-string-interpolation for details.
    + docker login -u **** --password-stdin
    + echo ****
    WARNING! Your password will be stored unencrypted in /var/jenkins_home/.docker/config.json.
    Configure a credential helper to remove this warning. See
    https://docs.docker.com/engine/reference/commandline/login/#credentials-store

    Login Succeeded
    [Pipeline] sh
    Warning: A secret was passed to "sh" using Groovy String interpolation, which is insecure.
             Affected argument(s) used the following variable(s): [USER]
             See https://jenkins.io/redirect/groovy-string-interpolation for details.
    + docker push ****/demo-app:1.1.0-35
    The push refers to repository [docker.io/****/demo-app]
    1f77559c1757: Preparing
    bf06c615cf19: Preparing
    0f30260f3ab9: Preparing
    6d0edcc4175b: Preparing
    887a67b27874: Preparing
    a49d675cd49c: Preparing
    8e012198eea1: Preparing
    a49d675cd49c: Waiting
    8e012198eea1: Waiting
    0f30260f3ab9: Pushed
    887a67b27874: Pushed
    6d0edcc4175b: Pushed
    1f77559c1757: Pushed
    8e012198eea1: Pushed
    bf06c615cf19: Pushed
    a49d675cd49c: Pushed
    1.1.0-35: digest: sha256:519fef9c344983bb07165569ac6d5aef9703837efb8c219847b8e2e262ad157c size: 1787
    [Pipeline] }
    [Pipeline] // withCredentials
    [Pipeline] }
    [Pipeline] // stage
    [Pipeline] }
    [Pipeline] // withEnv
    [Pipeline] }
    [Pipeline] // node
    [Pipeline] End of Pipeline
    Finished: SUCCESS


The final stage would be committing the changes due to version change to the git repository. Since logging in by username and password has been deprecated, we should use ssh authentication. We need to generate ssh key on the docker container and add the public key to the git repository to be able to push to it. To test it, we can clone the repository manually into the docker container which then adds the host to the trusted list as well.

The final Jenkinsfile is as following:

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


The automatic commit to git can be seen:

![image](https://user-images.githubusercontent.com/18715119/211758066-ad920288-a64e-42b5-ae21-34df4b5d8b5e.png)

The version chanage is indeed reflected in the docker image:

![image](https://user-images.githubusercontent.com/18715119/211757708-5e5a8787-ff0e-4209-b1b4-56070d44691e.png)


## EXERCISE 3: Manually deploy new Docker Image on server
After the pipeline has run successfully, you:

* Manually deploy the new docker image on the droplet server.

**Solution:**

After ssh into the server, we can do a docker login and download the generated image and run it.


    # Input username and password after docker login.
    docker login

    docker run -p 3000:3000 arshashiri/demo-app:1.2.0-39

After opening the port 3000, the website is reachable!

![image](https://user-images.githubusercontent.com/18715119/211760691-b0e523fd-eb29-43c0-935a-a33f685301bb.png)
