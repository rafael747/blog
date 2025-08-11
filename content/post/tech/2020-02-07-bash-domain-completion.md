---
date: '2020-02-07'
title: Domain completion for linux network tools
image: /img/bdc/bdc.png
url: '/tech/:slug'
categories: ['tech']
---

Bash domain completion for some linux network tools

<!--more-->

Link to the github project: https://github.com/rafael747/bash-domain-completion

## Domain list ##

Domains extracted from:

 - Amazon Alexa Top Sites (top 50 from each category)
   - https://www.alexa.com/topsites/category/Top/Computers
   - https://www.alexa.com/topsites/category/Top/Computers/Internet
   - https://www.alexa.com/topsites/category/Top/Computers/Hacking
   - https://www.alexa.com/topsites/category/Top/Computers/Open_Source
   - https://www.alexa.com/topsites/category/Top/Computers/Programming
   - https://www.alexa.com/topsites/category/Top/Computers/Security

 - https://github.com/chubin/awesome-console-services

 - https://www.youtube.com/watch?v=PmiK0JCdh5A


## Instalation ##
 
```
   cp top_domains.txt /opt/
   cp domain-completion /etc/bash_completion.d/
   cp keep-domains-updated /etc/cron.weekly/     # to keep top_domains.txt file updated
```

## Usage ##

You can use it already for a set of commands: **curl mtr ping wget host dig**

Just type the command and then press "tab" to see the suggestions

## How this works ##

 - top_domains.txt

This is the word list for the domains generated from the given sources

 - domain-completion

This is the configuration file for bash completion. You can change it to assign the domain completion for another commands

 - keep-domains-updated

This is a bash script that keeps the word list updated in a week basis

* * *
