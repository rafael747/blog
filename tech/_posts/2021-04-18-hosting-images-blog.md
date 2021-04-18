---
layout: post
title: How I host images for the blog
description: >
  How I host images for the blog
image: https://drive.google.com/uc?export=view&id=1wY4QPM-NI1okZ9o5dXvLv61E8T10Nz4i
noindex: true
---

Today I will show you how I host the images used in the posts. There are many methods you can use, however I found this one to be the most practical, with no additional tools or services needed.

Despite all the methods available to host images and embed them in a static blog. I chose to use only services that I already use (and you probably use them too).

![](https://drive.google.com/uc?export=view&id=1FsBYRjwNCkYcf_TisAqE-TQ-TGE5CZ_1)

I've been using Google Drive for years, and since I have an Android Phone, all of my photos are also stored in Google Photos.

This way, all I need to do when creating a new post is to select some photos from my phone's gallery (you can access it [here](https://photos.google.com/)), and put on a shared folder in Drive.

## How to embed photos on the Blog

First, you need place your image files in a publicly accessible folder. People who access the blog also need to access your images.

![](https://drive.google.com/uc?export=view&id=1yNSxkXOUTHdNijapbkOVA6GYcrr3mQ0X)

In my case, I set the permission on the folder, so I don't need to do that for every image inside. I use the following folder structure in my Drive:

<pre>
Google Drive/
└── Blog
    ├── one-post
    │   ├── 01.jpg
    │   └── 02.jpg
    └── other-post
        ├── 01.jpg
        └── 02.jpg
</pre>

> In this case, I only had to define the "Blog" folder as public, just once

With the image in the right place, go to "Share" and then click on "Copy link"

You will get something like this:

<pre>https://drive.google.com/file/d/<span style="color: #ff0000;">1yNSxkXOUTHdNijapbkOVA6GYcrr3mQ0X</span>/view?usp=sharing</pre>

Only the ID (in red) is important to us. Now, just put the ID in the following URL

<pre>https://drive.google.com/uc?export=view&amp;id=<span style="color: #ff0000;">PutTheIdHere</span></pre>

As I'm writing my Blog posts in Markdown, a ready-to-use link looks like this:

<pre> ![](https://drive.google.com/uc?export=view&id=1yNSxkXOUTHdNijapbkOVA6GYcrr3mQ0X) </pre>

Unfortunately, it is necessary to get each image ID to generate links for my posts. Wouldn't be great if we have a way to automate this process?

## Automating this process

For long posts with many images, this process can take a long time. So I had to find a way to generate links to my images in a faster way.

First, I tried to write some code that accesses my Google Drive and get the IDs for each image in a folder. Although this would work for sure, I was not happy to deal with different libraries, authentication methods and to create custom "APPs" to do such a simple job.

At that point, I was glad to find a Google service that helped a lot: Google Apps Script

![](https://drive.google.com/uc?export=view&id=1SFYns8yCjuo7OimhDqYktnkJsdc653xM)

With Google Apps Script, you simply write the code to interact with some Google services. It is like a script file that stays in your Google Drive and you can run it on your own account.

Without having to deal with anything else, I write the following script:

```js
function doGet(e) {
  var folder = DriveApp.getFolderById('1nLOhpzheVXoVDLarVPzE-HPBZkVEFkjN');
  var files = folder.getFiles();
  
  var ordered = [];
  // creates an array of file objects
  while (files.hasNext()) {
    var file = files.next();
    ordered.push({name: file.getName(), id: file.getId()});
  }

  // sorts the files array by file names alphabetically
  ordered = ordered.sort(function(a, b){
    var aName = a.name.toUpperCase();
    var bName = b.name.toUpperCase();
    return aName.localeCompare(bName);
  });
  
  var output = ContentService.createTextOutput("");
  ordered.forEach(function(file){
    output.append(Utilities.formatString("![](https://drive.google.com/uc?export=view&id=%s)", file.id))
    output.append("\n\n")
  });

  return output;
}
```

This code simply prints a markdown formatted URL for each image in a Google Drive Folder

> For now, the folder ID is hardcoded. However I need to open the script to run it, so it is an easy task to change the ID in the process.

The only remaining step is to open the script, change the folder ID and Deploy as a web app. You will get a URL like this

<pre>https://script.google.com/macros/s/AKfycbwwWGJxn5wasGnoi_SqukBWuz0N_FoxZJGlcIEcY0rL56X5e65_/exec</pre>

When you access the created link, you will see a simple page with the links, ready to be pasted in your Markdown file

![](https://drive.google.com/uc?export=view&id=11X5a2mZe4cAWaT0ywe9LkF6DcEOcXp60)


> In this case, there are only 3 images (this own post). However, for a post with many images, this saves me a lot of time.


* * *
