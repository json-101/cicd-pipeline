#! /bin/bash

#1. create separate bridge network called "jenkins"
#   purpose: to separate from the default docker network
docker network create jenkins

#2. run docker:dind Docker image
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind --storage-driver overlay2

#3. create & build the Dockerfile script that is in this repo
docker build -t jenkins-json:latest

#4. run my docker image that I just created "jenkins-json:latest"
docker run --name jenkins-json --restart=on-failure --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-json:latest