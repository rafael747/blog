---
date: '2025-08-21'
title: 'Using Cloudflare R2 for Images'
image: "/cdn/2025-08-21-using-r2-for-images/hugo-cloudflare-r2.png"
url: '/tech/:slug'
categories: ['tech']
---

I decided to change how I'm hosting images for the blog.

<!--more-->

## In the beginning

When I started the blog back in 2019 my goal was to keep it simple and stick to free tools (the domain registration is still the only cost I have so far)

My main goal was to not bloat git with binary files (which I end up doing for some images from the first posts)

Then I decided to use Google Drive to host images for the blog

![](/cdn/2025-08-21-using-r2-for-images/google-drive.png)

Check the original post [here](/tech/how-i-host-images-for-the-blog-outdated/)

---

## Issues with Google Drive

Initially everything was working just fine

The first issue was caused by the [policy change regarding third party cookies](https://workspaceupdates.googleblog.com/2023/10/upcoming-changes-to-third-party-cookies-in-google-drive.html)

All of sudden the images where not loading anymore with 403 errors

Some investigation led me to [this bug report](https://issuetracker.google.com/issues/319531488?pli=1
), where Google took 20 days to clarify that this is the intended behavior and this [will not be fixed](https://issuetracker.google.com/issues/319531488#comment175)

Meanwhile, a workaround was shared in the thread

```diff
- https://drive.google.com/uc?export=download&id=xxxxx
+ https://drive.google.com/thumbnail?sz=w1000&id=xxxxx
```

This workaround was easy to implement, and despite reducing the image quality, was the chosen solution.

That worked good enough until recently I started getting frequent 429 errors (Too many requests).

<kbd>![](/cdn/2025-08-21-using-r2-for-images/429-errors.png)

Seems like Google is trying to close the circle on this workaround as well.

The final issue regarding Google Drive is the not so generous storage size, that is shared between Gmail, Photos and other services

<kbd>![](/cdn/2025-08-21-using-r2-for-images/google-storage.png)

---

## Alternatives

I wanted to keep things simple, hopefully using tools that I'm already used to.

 - Git LFS (Large File Storage)

Seems like a perfect solution for the issue: Keep the binary files virtually together with the code, in the same platform.

Unfortunately the last part of this sentence turns out to be a blocker.

Since I'm using GitHub, the logical solution would be to use GitHub's LFS service, but this turns out to be not super competitive regarding quotas

It is possible to use Git LFS with another provider, like Cloudflare R2: https://dbushell.com/2024/07/15/replace-github-lfs-with-cloudflare-r2-proxy/

This would require a proxy server to interact with Git LFS and store files in R2. This would solve the quota issue with GitHub, but would also require maintaining another component to make it work, increasing the complexity.

Another issue is that Git LFS is not included with git, being required to manually install it.

```bash
$ git lfs
git: 'lfs' is not a git command. See 'git --help'.
```

This is not exactly a blocker, but adds additional complexity to the process.

---

## Chosen Solution

### **Cloudflare R2**

<kbd>![](/cdn/2025-08-21-using-r2-for-images/hugo-cloudflare-r2.png)

The free tier seems good enough to host images (and other assets) for a simple blog.
The Git LFS integration seems very interesting. However, using it directly will be simpler.

R2 also has a S3-compatible API. This allows the use of s3 tools, like AWS CLI.

### Downsides

The major downside in my opinion is the **requirement** to have the domain DNS managed by Cloudflare in order to create a custom subdomain name for a R2 bucket.

This would be a blocker if I was managing the DNS somewhere I like. Since it was not the case, I didn't mind switching to Cloudflare.

> A workaround would be to use a (ugly) development URL. Cloudflare mention that this URL is rate-limited, but I didn't test its limits.

---

## Migration steps

I want to have a simple setup where I can write the posts with the images in my local machine, and when I'm ready, easily switch to the "cdn" backed by R2.

In order to accomplish this I followed this [documentation](https://www.heykyo.com/posts/2025/05/comprehensive-guide-to-cloudflare-r2-image-integration-in-hugo/), with some adjustments.

The workflow looks like this:

 - Start writing a blog post
 - Have the images in my local machine
 - Reference the images locally when developing with `hugo server`
 - When I'm done with local development, upload the images to R2
 - Automatically switch image references to R2 when building it: `hugo build`

 In order to accomplish this I created a [Hugo Partial](https://gohugo.io/functions/partials/include/) to do the URL manipulation depending on the [Hugo Environment](https://gohugo.io/functions/hugo/environment/).
 This partial file makes it easier to apply this transformation in multiple places.

 > It is required to include `cdnBaseURL` and `cdnLocalAssetPrefix` in `config.toml` 
 > - **cdnBaseURL**: Custom URL of the R2 Bucket
 > - **cdnLocalAssetPrefix**: Static asset prefix (folder) that will automatically be switched to `cdnBaseURL`

  - `layouts/partials/cdn-image.html`
  ```go
{{- /*
CDN Image URL Transformer

This partial transforms local CDN paths to full CDN URLs when building for production.
Input: Image path (string)
Output: Transformed URL (string)
*/ -}}

{{- $cdnBaseURL := site.Params.cdnBaseURL | default "" }}
{{- $cdnLocalAssetPrefix := site.Params.cdnLocalAssetPrefix | default "" }}

{{- $finalUrl := . }}

{{- if and (ne $cdnBaseURL "") (ne $cdnLocalAssetPrefix "") -}}

    {{- /* Determine if this image should be transformed */ -}}
    {{- $isRemoteImage := findRE `^https?` . }}
    {{- $isLocalCdnPath := and (not $isRemoteImage) (hasPrefix . $cdnLocalAssetPrefix) }}

    {{- /* Transform URL if needed */ -}}
    {{- if and $isLocalCdnPath (eq hugo.Environment "production") -}}
        {{- /* Extract relative path from CDN prefix */ -}}
        {{- $relativePath := strings.TrimPrefix $cdnLocalAssetPrefix . }}

        {{- /* Build full CDN URL */ -}}
        {{- $finalUrl = printf "%s/%s" (strings.TrimSuffix "/" $cdnBaseURL) (strings.TrimPrefix "/" $relativePath) }}
    {{- end -}}
{{- end -}}

{{- return $finalUrl -}}
  ```

Right now this partial is used in 2 locations:

 - `layouts/_default/_markup/render-image.html`
 ```diff
+   {{- $newDestination := partial "cdn-image.html" .Destination -}}

-   <img src="{{ .Destination | safeURL }}"
+   <img src="{{ $newDestination | safeURL }}"
      {{- with .PlainText }} alt="{{ . }}"{{ end -}}
      {{- with .Title }} title="{{ . }}"{{ end -}}
    >
    {{- /* chomp trailing newline */ -}}
 ```

 - `layouts/post/summary.html`
 ```diff
     <div class="post-summary">
      {{ $post := . }}
      {{ with .Params.image }}
+       {{- $imageUrl := partial "cdn-image.html" . -}}
          <a href="{{ $post.RelPermalink }}" class="post-image-link">
          <img 
-           src="{{ . }}" 
+           src="{{ $imageUrl }}" 
            alt="{{ $post.Title }}" 
            class="post-featured-image"
            style="aspect-ratio: 5/3; object-fit: cover;"
            no-fancybox
          >
        </a>
      {{ end }}
 ```
 ---

### Local development

When writing blog posts, I reference the images from the `static/cdn/` folder with `![](/cdn/${path-to-file})`

> During build, everything from `static/` is copied over to the website root

```bash
$ tree static/cdn 
static/cdn
└── 2023-04-04-ricoh-kr10s-part1
    ├── IMG-20220905-WA0004.jpg
    ├── IMG_20230513_160201.jpg
    ├── SKM_C45823051212090_0001.jpg
    ├── SKM_C45823051212090_0002.jpg
    ├── SKM_C45823051212090_0003.jpg
    ├── SKM_C45823051212090_0004.jpg
    ├── SKM_C45823051212090_0005.jpg
    ├── SKM_C45823051212090_0006.jpg
    ├── SKM_C45823051212090_0015.jpg
    └── SKM_C45823051212090_0016.jpg
```

With `hugo server` it is possible to see that the files are loaded locally

<kbd>![](/cdn/2025-08-21-using-r2-for-images/local-images.png)

I also updated the `.gitignore` to make sure I'll not commit them:

```diff
  # Hugo
  public/
  resources/
  .hugo_build.lock
+ static/cdn/
```
---

## Publishing the Website

Once the local development is done, it is needed to upload the images to R2.

This is as easy as dragging and dropping the folder there:

<kbd>![](/cdn/2025-08-21-using-r2-for-images/upload-to-r2.png)

When manipulating multiple files it is convenient to use AWS CLI to interact with Cloudflare R2.

 ```bash
 aws configure #create a profile with R2 credentials
 aws s3 sync static/cdn/ s3://bucket/ --endpoint-url https://your-endpoint.r2.cloudflarestorage.com
 ```

When building with `hugo build`, all references to `cdnLocalAssetPrefix` (`/cdn/` in my case) will be replaced by `cdnBaseURL` (`cdn.teffa.dev` in my case).

> It is also possible to simulate the same behavior with `hugo server -e production`

<kbd>![](/cdn/2025-08-21-using-r2-for-images/remote-images.png)

---

## Migrating existing images

I used this AI-generated python script to migrate the images from Google Drive

In short, the script will:

 - Locate Google Drive links: `https://drive.google.com/thumbnail?sz=w1000&id=XXX`
 - Download the image with `https://drive.google.com/uc?export=download&id=XXX` under `/static/cdn/${post_filename}/XXX`
 - Replace the Google Drive links with the local references

{{% admonition type="info" title="replace_gdrive_images.py" details="true" %}}

 ```python
#!/usr/bin/env python3
"""
Script to download Google Drive images from markdown blog posts and replace links with local references.
"""

import os
import re
import sys
import requests
from pathlib import Path
from urllib.parse import urlparse, parse_qs
import argparse

def extract_file_id_from_url(url):
    """Extract the file ID from a Google Drive thumbnail URL."""
    parsed = urlparse(url)
    if parsed.netloc == 'drive.google.com' and '/thumbnail' in parsed.path:
        query_params = parse_qs(parsed.query)
        return query_params.get('id', [None])[0]
    return None

def download_file(file_id, output_path):
    """Download a file from Google Drive using the file ID."""
    download_url = f"https://drive.google.com/uc?export=download&id={file_id}"
    
    try:
        response = requests.get(download_url, stream=True)
        response.raise_for_status()
        
        # Try to get filename from Content-Disposition header
        content_disposition = response.headers.get('Content-Disposition', '')
        filename = None
        
        if 'filename=' in content_disposition:
            filename = content_disposition.split('filename=')[1].strip('"')
        
        # If no filename found, use file ID with .jpg extension as fallback
        if not filename:
            filename = f"{file_id}.jpg"
        
        file_path = output_path / filename
        
        with open(file_path, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        print(f"Downloaded: {filename}")
        return filename
        
    except requests.RequestException as e:
        print(f"Error downloading file {file_id}: {e}")
        return None

def process_markdown_file(md_file_path, cdn_folder_path):
    """Process the markdown file to download images and update links."""
    md_file_path = Path(md_file_path)
    cdn_folder_path = Path(cdn_folder_path)
    
    if not md_file_path.exists():
        print(f"Error: File {md_file_path} does not exist.")
        return
    
    # Read the markdown file
    with open(md_file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Find all Google Drive thumbnail links
    gdrive_pattern = r'https://drive\.google\.com/thumbnail\?sz=w1000&id=([a-zA-Z0-9_-]+)'
    matches = re.findall(gdrive_pattern, content)
    
    if not matches:
        print("No Google Drive links found in the file.")
        return
    
    print(f"Found {len(matches)} Google Drive links.")

    # Create folder with same name as .md file (without extension)
    folder_name = md_file_path.stem
    folder_path = cdn_folder_path / folder_name
    
    if not folder_path.exists():
        folder_path.mkdir(parents=True)
        print(f"Created folder: {folder_path}")
    
    # Download each file and update content
    for file_id in matches:
        filename = download_file(file_id, folder_path)
        if filename:
            # Replace the thumbnail URL with local reference
            old_url = f"https://drive.google.com/thumbnail?sz=w1000&id={file_id}"
            new_url = f"/cdn/{folder_name}/{filename}"
            content = content.replace(old_url, new_url)
            print(f"Replaced: {old_url} -> {new_url}")
    
    # Write the updated content back to the file
    with open(md_file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"\nProcessing complete! Updated {md_file_path}")
    print(f"Images downloaded to: {folder_path}")

def main():
    parser = argparse.ArgumentParser(
        description="Download Google Drive images from markdown blog posts and update links"
    )
    parser.add_argument(
        "file", 
        help="Path to the markdown file to process"
    )
    parser.add_argument(
        "--cdn-folder",
        help="Path to the cdn folder to download images to"
    )
    
    args = parser.parse_args()
        
    process_markdown_file(args.file, args.cdn_folder)

if __name__ == "__main__":
    main() 
 ```

{{% /admonition %}}

  - Usage: 
  
  ```bash
  python replace_gdrive_images.py --cdn-folder static/cdn content/post/places/2023-04-04-ricoh-kr10s-part1.md
  ```



