---
layout: post
title: Satellite's DVB receiver monitoring with Zabbix
description: >
  How to monitor DVB receiver stats using Zabbix
image: /assets/img/zabbix-cmcs/zabbix-gnc-g2.png
noindex: true
---

Once you have a setup up and running, it is very important to monitor DVB receiver statistics. You can receive alerts for triggers via Email, if configured in Zabbix.

Link to the github project: https://github.com/rafael747/zabbix-cmcs-template

## Instalation ##
 
 - Make sure you have **cmcs** client installed and available in PATH (https://novra.com/downloads)
 - Copy/link **cmcstats.sh** to **/usr/local/bin/cmcstats**
 - Fill **IP** and **PW** info in **/usr/local/bin/cmcstats**
 - Copy **cmcstats.conf** to **/etc/zabbix/zabbix_agentd.conf.d/**
 - Restart zabbix-client service

* You can test the script before adding the template to your host

```
   cmcstats SIGS   #to print Signal Strength
   cmcstats SIGL   #to print Signal Lock Status
   cmcstats        #to print all information
```

## On Zabbix server
 
 - Import **zbx_cmcs_template.xml** in Zabbix server and add it to your host
 

* * *
 
## Latest data
![](/assets/img/zabbix-cmcs/zabbix-gnc.png)

## Triggers
![](/assets/img/zabbix-cmcs/zabbix-gnc-t.png)

## Graph
![](/assets/img/zabbix-cmcs/zabbix-gnc-g.png)
 
