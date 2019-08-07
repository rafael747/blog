---
layout: post
title: Share a local port using localhost.run
description: >
  Create a public URL for a local service, no worries about firewall, NAT, etc..
image: /assets/img/localhost-run/site.png
noindex: true
---

Sometimes it is very useful to share a local port in your computer to the Internet

## localhost.run

It is a free service that allow an user to share local URL as a public available URL.

For example:

```bash
$ PORT=8080 ./yourapp &
Serving on port 8080 ...
$ ssh -R 80:localhost:8080 ssh.localhost.run
Connect to http://yourproject.localhost.run or https://yourproject.localhost.run
```

This allows a user to access a service running in your computer on port 80

 - link to the project: http://localhost.run/

* * *

## How does it works

It uses the SSH protocol to forward the requests made the the public URL to the configured local port.


```
-R port:host:hostport
             Specifies that connections to the given TCP port or Unix socket
             on the remote (server) host are to be forwarded to the local
             side.
```

This way, then doing this:

`ssh localhost.run -R 80:localhost:80`

Requests to this public URL will be forwarded to the given local port


{% asciicast 260271 %}


To share a different local port you can change **localhost:80** to **localhost:4000**

`ssh localhost.run -R 80:localhost:4000`

> this way, conections will be forwarded to port 4000 on localhost


You can even allow a connection to another host on your network. Do not worry about firewall or NAT/port forwarding.

`ssh localhost.run -R 80:otherhost:80`


To generate a custom public URL you can use a different username on the ssh connection:

`ssh somecustomname@localhost.run -R 80:localhost:4000`

This way, the generated URL will be: http://somecustomname.localhost.run (if no one is using this username already)

* * *

## Use Cases

### Allow access to a service listening on 127.0.0.1

I think this is the default use case for this service,
I usually use it to access some unpublished pages of this blog on my phone

Since the **bundle exec jekyll serve** command will listen on **127.0.0.1:4000**

I could'n access it from my phone, even on the same network.

> I can change jekyll configuration to listen on 0.0.0.0, but I still need to be in the same network. (if my phone is using mobile data it won't work)

* * *

### Testing a webhook in a local environment 

When testing a webhook, it is useful to get the requests on your local machine

This can be a bit hard when working in closed networks, with private IP ranges.

With localhost.run you can create a public URL to your local development project.

* * *

### Share a local file


You can also use this service to share local files over the Internet.

With the default nginx instalation you can put some files on the webserver root folder:

```bash
rafael@tyr:/var/www/html$ cat test.txt 
This is a test document.

rafael@tyr:/var/www/html$ sudo service nginx start 
rafael@tyr:/var/www/html$ ssh localhost.run -R 80:localhost:80 
Connect to http://rafael.localhost.run or https://rafael.localhost.run
```

In another machine:

```bash
rafael@tyr:~$ curl https://rafael.localhost.run/test.txt
This is a test document.
```

Now you can access these files anywhere:


