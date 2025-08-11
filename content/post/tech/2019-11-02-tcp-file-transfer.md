---
date: '2019-11-02'
title: TCP a simple tool for moving files around
image: /img/tcp/term.png
url: '/tech/:slug'
categories: ['tech']
---

A simple program writen in golang for sending and receiving files in the same network.

<!--more-->

Link to the github project: https://github.com/rafael747/tcp

## Instalation ##
 
 - Make sure you have the GO compiler and **$GOPATH** defined 

```
    go get github.com/rafael747/tcp
    go install github.com/rafael747/tcp
```
> This will install the **tcp** binary to **$GOPATH/bin/tcp**. If you have **$GOPATH/bin** in your $PATH, you can use it already. Otherwise, you can copy or link it to your $PATH e.g. /usr/local/bin

* * *

 - You can also use the prebuilt packages in **prebuilt/**
```
    wget https://github.com/rafael747/tcp/raw/master/prebuilt/tcp_0.1_amd64.deb
    sudo dpkg -i tcp_0.1_amd64.deb  #this will install tcp under /usr/local/bin
```
> There are .deb packages and .exe binaries in **prebuilt** folder, for i386 and amd64

* * * 

## Usage ##

 - To receive a file in the working directory

```
tcp
```

 - To send a file to another host

```
tcp file host
```

> the host can be an IP address or a name, check your DNS configuration

* * * 

## TODO ##

**This is a WIP, so there are a lot of things to improve:**

 - The hosts must be acessible directly. You can use a SSH to tunnel the traffic through a NAT or a firewall.
 - Currently, using only port 2000/tcp
 - No encryption. You can also use a SSH tunnel for that 
 
