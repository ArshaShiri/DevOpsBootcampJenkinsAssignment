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

Creating Server:


The following droplet is created:

![image](https://user-images.githubusercontent.com/18715119/211541922-3b364fe6-643c-47a3-8425-5c0eec5a1d68.png)

Installing Jenkins:


After installing docker, we run the following command to install Jenkins:

    docker run -p 8080:8080 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home jenkins/jenkins

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
