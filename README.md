# Inspiration

Inspiration is a Ruby script creating a portfolio of images from an RSS feed.

More exactly: 

  1. It takes a delicious.com RSS feed
  2. Scraps / screenshots webpages the feed items are pointing at
  3. Resizes images with ImageMagick to thumbnails and normal sizes
  4. Uploads images to Amazon S3
  5. Generates a HTML to show the portfolio
  

## Why?

Check out the result: [http://www.shopledge.com/portfolio/inspiration/](http://www.shopledge.com/portfolio/inspiration/)

The input was: [http://feeds.delicious.com/v2/rss/csbartus/inspiration?count=100](http://feeds.delicious.com/v2/rss/csbartus/inspiration?count=100)

## Based on

  1. simple-rss
  2. open-uri
  3. right_aws
  4. webkit2png.py
  


## How it works?

  1. You don't have to regenerate all images, just the latest items added to your Delicious bookmarks
  2. You can set the size for all versions of images
  3. Already existing screenshots will be skipped
  4. Already uploaded files will be skipped
  5. You can run modularly the script, step by step, or skipping directly to HTML generation



## Configuration options

### RSS
RSS = 'http://feeds.delicious.com/v2/rss/csbartus/inspiration?count=100'

### Images
IMG_DIR = 'images'

IMG_THUMB_SIZE = '400x300'

IMG_THUMB = "_thumb"

IMG_SIZE = '600x'

IMG_FINAL = "_large"

IMG_FILENAME_SIZE = 50 

IMG_TIMEOUT = 20 // for waiting for screenshots


### Amazon S3
S3_ID = ""

S3_KEY = ""

S3_BUCKET = "bucket-name"

S3_PUBLIC = 'https://s3-eu-west-1.amazonaws.com/' // right_aws doesn't get correctly the public link of the uploaded image



### HTML generation
HTML_FILE = "inspiration.html"

HTML_ITEM_PREFIX = '' // lists, divs, etc. ... containers for the image

HTML_ITEM_SUFFIX = '' // Closing tag for PREFIX

HTML_TOGGLE = '' // tags for toggle larger images. See source for example



## Goodies

This example @shopledge is equipped with the following Javascript to load larger images dinamically
[https://gist.github.com/816883](https://gist.github.com/816883)
