---
date: '2025-08-06'
title: 'Goodbye Jekyll, Hello Hugo'
image: /img/jekyll-to-hugo/jekyll-to-hugo.png
url: '/tech/:slug'
categories: ['tech']
---

I took a long break from writing to the blog due to a severe case of laziness. After a long time I was not even able to run it locally again :(

So now I want to restart my blogging hobby with fresh content, design, and a new framework. This post is about how I migrated my blog from Jekyll to Hugo.

<!--more-->

![](/img/jekyll-to-hugo/jekyll-to-hugo.jpg)

I had a good time with the Jekyll platform. The main issue for me was about managing gem updates, ruby versions and having a stable local development.

Since I don't post often, I would rather have a framework with the least amount of moving parts. Hugo seems to be a bit better in this regard (let's see how long it will last).

## Why not Jekyll

At first I thought about just updating the ruby gem, which of course did not happen nicely. Then I thought about updating the jekyll base altogether, which also caused issues with my version of ruby. 

![](/img/jekyll-to-hugo/gems.png)

In the end I was happy to step out of the framework instead of fixing all my mess.

## Why Hugo

No specific reason. Hugo seems easier to maintain and more lightweight.

```
$ hugo build
Start building sites … 
hugo v0.148.1+extended+withdeploy darwin/arm64


                  │ EN 
──────────────────┼────
 Pages            │ 71 
 Paginator pages  │  6 
 Non-page files   │  0 
 Static files     │ 72 
 Processed images │  0 
 Aliases          │  6 
 Cleaned          │  0 

Total in 82 ms
```

Build times seem pretty good too, compared to Jekyll.

## Hugo Theme

The theme used is called ["Even"](https://github.com/olOwOlo/hugo-theme-even), with some small modifications to match the layout of the jekyll version used previously

### Custom post cover image

In order to display a cover image for each post I had to create a custom `layouts/post/summary.html` file with this additional content:

```diff
....
  <!-- Content -->
  <div class="post-content">
    <div class="post-summary">
+      {{ with .Params.image }}
+      <img src="{{ . }}" alt="" no-fancybox style="aspect-ratio: 5/3; object-fit: cover;">
+      {{ end }}
      {{ .Summary }}
    </div>
    <div class="read-more">
      <a href="{{ .RelPermalink }}" class="read-more-link">{{ T "readMore" }}</a>
    </div>
  </div>
....
```

This will add the image in the `image` parameter in the front matter (if any) as the post image cover.

The `no-fancybox` tag is used to disable the `fancybox` wrapping for images in the home page.
In order to do this a custom `js` resource was created in `static/js/custom-fancybox.js`:

```js
$(document).ready(function() {
  // Remove fancybox wrapper from images with data-no-fancybox
  $('img[no-fancybox]').each(function() {
    if ($(this).parent().hasClass('fancybox')) {
      $(this).unwrap();
    }
  });
}); 
```

This custom `js` file needs to be included in `config.toml`
```toml
...
customJS = ['custom-fancybox.js']
...
```

## Migration

Migrating the old posts was a simple task, since the format almost matches the one expected by Hugo.

```diff
   ---
-  layout: post
+  date: '2023-04-07'
-  title: 2023-04-07 - Schweizer Jakobsweb Part 1 (Rorschach -> Rapperswil)
+  title: Schweizer Jakobsweb Part 1 (Rorschach -> Rapperswil)
   image: https://drive.google.com/thumbnail?sz=w1000&id=1PGPh6AhhjzHbJmqk6TwUTPew4KSp9w3N
-  noindex: true
+  url: '/places/:slug'
+  categories: ['places']
   ---

   This is the Swiss part of the Jakobsweb starting in Rorschach, also called "Rorschacher Ast".

   You can find the all steps [here](https://camino-europe.eu/de/eu/switzerland/jakobswege-schweiz/bregenz-rorschach-einsiedeln-rorschacher-ast/), and other useful information as well. 

+  <!--more-->

   ## Munich -> Rorschach (train + boat)
```

The only difference was in the front matter definition, and the insertion of a tag to limit how much of the post will be displayed in the home page.

Nothing that an AI-generated bash script couldn't handle 

* * *

Hopefully it will be easier to maintain and we will have posts more often