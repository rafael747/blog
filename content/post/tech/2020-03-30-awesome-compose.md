---
date: '2020-03-30'
title: Docker compose samples for applications
image: /img/awesome-compose/docker-compose.png
url: '/tech/:slug'
categories: ['tech']
---

Application samples for project development kickoff

<!--more-->

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


## nginx-flask-mysql sample ##

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

If you have made modifications in the **Dockerfile**, you will need to do the following to bring the whole stack down, and build the docker image again.

```
docker-compose down
docker-compose up -d --build
```

## Samples of Docker Compose applications with multiple integrated services

- [`ASP.NET / MS-SQL`](https://github.com/docker/awesome-compose/tree/master/aspnet-mssql) - Sample ASP.NET core application
with MS SQL server database.
- [`Go / NGINX / MySQL`](https://github.com/docker/awesome-compose/tree/master/nginx-golang-mysql) - Sample Go application
with an Nginx proxy and a MySQL database.
- [`Go / NGINX / PostgreSQL`](https://github.com/docker/awesome-compose/tree/master/nginx-golang-postgres) - Sample Go
application with an Nginx proxy and a PostgreSQL database.
- [`Java Spark / MySQL`](https://github.com/docker/awesome-compose/tree/master/sparkjava-mysql) - Sample Java application and
a MySQL database.
- [`NGINX / Flask / MongoDB`](https://github.com/docker/awesome-compose/tree/master/nginx-flask-mongo) - Sample Python/Flask
application with Nginx proxy and a Mongo database.
- [`NGINX / Flask / MySQL`](https://github.com/docker/awesome-compose/tree/master/nginx-flask-mysql) - Sample Python/Flask
application with an Nginx proxy and a MySQL database.
- [`NGINX / Go`](https://github.com/docker/awesome-compose/tree/master/nginx-golang) - Sample Nginx proxy with a Go backend.
- [`React / Spring / MySQL`](https://github.com/docker/awesome-compose/tree/master/react-java-mysql) - Sample React
application with a Spring backend and a MySQL database.
- [`React / Express / MySQL`](https://github.com/docker/awesome-compose/tree/master/react-express-mysql) - Sample React
application with a Node.js backend and a MySQL database.
- [`React / Rust / PostgreSQL`](https://github.com/docker/awesome-compose/tree/master/react-rust-postgres) - Sample React
application with a Rust backend and a Postgres database.
- [`Spring / PostgreSQL`](https://github.com/docker/awesome-compose/tree/master/spring-postgres) - Sample Java application
with Spring framework and a Postgres database.  
## Single service samples
- [`Angular`](https://github.com/docker/awesome-compose/tree/master/angular)
- [`Spark`](https://github.com/docker/awesome-compose/tree/master/sparkjava)
- [`VueJS`](https://github.com/docker/awesome-compose/tree/master/vuejs)
- [`Flask`](https://github.com/docker/awesome-compose/tree/master/flask)
- [`PHP`](https://github.com/docker/awesome-compose/tree/master/apache-php)
- [`Traefik`](https://github.com/docker/awesome-compose/tree/master/traefik-golang)
- [`Django`](https://github.com/docker/awesome-compose/tree/master/django)
## Basic setups for different platforms (not production ready - useful for personal use) 
- [`Gitea / PostgreSQL`](https://github.com/docker/awesome-compose/tree/master/gitea-postgres)
- [`Nextcloud / PostgreSQL`](https://github.com/docker/awesome-compose/tree/master/nextcloud-postgres)
- [`Nextcloud / Redis / MariaDB`](https://github.com/docker/awesome-compose/tree/master/nextcloud-redis-mariadb)
- [`Wordpress / MySQL`](https://github.com/docker/awesome-compose/tree/master/wordpress-mysql)
- [`Prometheus / Grafana`](https://github.com/docker/awesome-compose/tree/master/prometheus-grafana)


* * *
