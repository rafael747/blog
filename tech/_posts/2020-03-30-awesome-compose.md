---
layout: post
title: Docker compose samples for applications
description: >
  docker-compose samples
image: /assets/img/awesome-compose/docker-compose.png
noindex: true
---

Application samples for project development kickoff

Link to the original post on docker blog: https://www.docker.com/blog/awesome-compose-app-samples-for-project-dev-kickoff

## Installing Docker and docker-compose ##

I usually use the following steps to get docker and docker-compose installed:

```
curl https://get.docker.com|sudo bash   #installs docker
sudo usermod -aG docker $your_user      #add your username to docker group

sudo curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

> 1.25.4 is current stable release of docker-compose for now

Updated instructions can be found [here](https://docs.docker.com/install/linux/docker-ce/ubuntu/) for docker and [here](https://docs.docker.com/compose/install/) for docker-compose.

## awesome-compose repository ##

To Clone the repository localy:

```
git clone https://github.com/docker/awesome-compose.git
cd awesome-compose
```

At the root of each sample there is the **docker-compose.yml**. It contains the definition and the structure of the application and instructions on how to wire the components of the application.


## To the samples ##

To start a sample stack with nginx, a flask app and mysql database, you can do the following 

```
cd nginx-flask-mysql
docker-compose up -d
```

Check there are three containers running, one for each service:

```
docker-compose ps
```

Since the 80 port is mapped to the host using the stack, you can use **curl** to test the application:

```
curl localhost:80
```

**This will work with most of the examples out of the box**

## Modify and update the application sample ##

Once you made modification to the sample, you can restart the services

```
docker-compose restart backend 		#to restart the service named backend
```

You can also use the the following to bring the whole stack down and up again

```
docker-compose down
docker-compose up -d
```

* * *
