---
date: '{{ now.Format "2006-01-02" }}'
draft: true
title: '{{ replace .File.ContentBaseName "-" " " | title }}'
image: "/img/wip.jpg"
url: '/{{ path.Base .Dir }}/:slug'
categories: ['{{ path.Base .Dir }}']

---

Some content that will be displayed in the home page

<!--more-->

Some contente that will not be displayed in the home page
