#### This project is for the Devops bootcamp assignment for Jenkins

## EXERCISE 1: Dockerize your NodeJS App
Configure your application to be built as a Docker image.

* Dockerize your NodeJS app

**Solution**

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