---
layout: post
title: Monitor Twilio balance using Zabbix
description: >
  How to monitor twilio balance using Zabbix
image: /assets/img/zabbix-twilio-template/za.png
noindex: true
---

There is a lot o projects and guides on how to configure Zabbix to send alerts using Twilio. But I haven't found how to monitor the Twilio balance using Zabbix.

This approach uses a Zabbix template with only http items, so all requests will be made by the zabbix server.

Link to the github project: https://github.com/rafael747/zabbix-twilio-template

## Instructions

 - Log in to the Zabbix Server Dashboard (no cli stuff needed) 
 - Import **template_twilio.xml** template
 - Create a new host for each twilio account you want to monitor

> These hosts don't need a zabbix-agent, all requests will be made by the zabbix server (you can use 127.0.0.1 for them)

![](/assets/img/zabbix-twilio-template/zabbix_host_a.png)

 - Grab your **SID** and **Auth Token** for each Twilio account

![](/assets/img/zabbix-twilio-template/twilio_sid_auth.png)

 - For each created host (twilio account) create the following **Macros**:
    - {$AUTH_TOKEN} -> your_twilio_account_auth_token
    - {$SID} -> your_twilio_account_sid

![](/assets/img/zabbix-twilio-template/zabbix_host_b.png)

 - Add the imported template to your new hosts

## Items

The only item is your twilio current balance value. But let me know if you would like to monitor other things in your twilio account, since it would be pretty easy to add to this template.

I used this documentation to make this template: https://www.twilio.com/docs/usage/api/account

## Triggers

There is a trigger for when the balance is below 5 dolars.

This value can be changed globaly in the template's macro configuration.

![](/assets/img/zabbix-twilio-template/zabbix_host_d.png)

But you can also change this for each account, in hosts Macros -> Inherited and host macros

![](/assets/img/zabbix-twilio-template/zabbix_host_c.png)

Now you can use Twilio to send alerts about your Twilio balance

* * *
