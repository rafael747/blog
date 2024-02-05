---
layout: post
title: Monitor domain expiration using Zabbix
description: >
  How to monitor domain expiration dates using Zabbix
image: /assets/img/zabbix-domain-check/zabbix_logo.png
noindex: true
---

It is very important to monitor multiple domain expiration dates when working for a big company. It is more useful when working with multiple registrars, even if you don't have access to these registrars accounts.

This approach uses a Zabbix template with discovery rules to make whois queries and parse answers. You can receive expiration alerts via Email, if configured in Zabbix.

Link to the github project: https://github.com/rafael747/Zabbix-Domain-Check

 
## Instructions

 - Log in to the Zabbix server
 - Clone the repository

```
git clone https://github.com/rafael747/Zabbix-Domain-Check ~/
cd ~/Zabbix-Domain-Check
```
 - Copy **domaindiscover.pl** to **/etc/zabbix/**

`cp domaindiscover.pl /etc/zabbix/`
 
 - Create **/etc/zabbix/domain.list** with domain list, one per line

```
teffa.online
teffa.dev
...
```

 - Copy **zabbix_agentd.d/domain_check.conf** to **/etc/zabbix/zabbix_agentd.d/**

`cp zabbix_agentd.d/domain_check.conf  /etc/zabbix/zabbix_agentd.d/`

 - Copy **domain-check.sh** to zabbix externalscripts (/usr/lib/zabbix/externalscripts)

`cp domain-check.sh /usr/lib/zabbix/externalscripts/`

 - Create directory **/var/cache/zabbix/domain.db** on zabbix server

`mkdir -p /var/cache/zabbix/domain.db`

 - Edit the necessary parameters in **domain-check.sh** script.

```
...
# Location of system binaries
AWK="/usr/bin/awk"
WHOIS="/usr/bin/whois"
...
...
# Zabbix server param

DOMAINDB="/var/cache/zabbix/domain.db"
ZABBIXSERVER="127.0.0.1"
ZABBIXPORT="10051"
ZABBIXHOST="Domains"
...
```

 - Import **zbx_templates/Template Domain check.xml** into your templates
 - Create host **Domains** (ip 127.0.0.1) and applay **template Domain check** on it.


![](/assets/img/zabbix-domain-check/zabbix_1.png)

![](/assets/img/zabbix-domain-check/zabbix_2.png)


 - Create crontab rule:

```0 0 * * * /usr/lib/zabbix/externalscripts/domain-check.sh -z 2>&1 > /dev/null```

* * *

## Latest Data

![](/assets/img/zabbix-domain-check/zabbix_3.png)

## Problems

![](https://drive.google.com/thumbnail?sz=w1000&id=1_XTGB8eTsGProJ_TMxMcdbEeVS3YE9LK)

## Trigger

 - You can receive alerts via email, if configured in Zabbix

![](/assets/img/zabbix-domain-check/zabbix_4.png)

* * *

 - To add new domain, just edit the **/etc/zabbix/domain.list**. The cronjob and the discovery rule will do the rest.
