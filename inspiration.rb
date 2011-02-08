# inspiration.rb
# - fetching an RSS feed and create screenshots for feed item urls
# - upload images to Amazon AWS S3
# - create a HTML file with these images



# RSS
# 
# the feed 
RSS = 'http://feeds.delicious.com/v2/rss/csbartus/inspiration'

# Images
#
# where to store images
IMG_DIR = 'images'

# thumbnail size
IMG_THUMB_SIZE = '400x300'

# thumbnail file name postfix
IMG_THUMB = "_thumb"

# final image size
IMG_SIZE = '600x'

# final image file nem postfix
IMG_FINAL = "_large"

# image file name length
IMG_FILENAME_SIZE = 50 


# Amazon S3
#
S3_ID = "AKIAIM4EGICY766JY2PA"
S3_KEY = "dJELxK7fO13rDAY0JLHa1TLSKDwNN21P1hy/dlvh"
S3_BUCKET = "webdesign-inspiration"
# right_aws doesn't get correctly the public link of the uploaded image
S3_PUBLIC = 'https://s3-eu-west-1.amazonaws.com/'



# HTML generation
#
HTML_FILE = "index.html"
HTML_ITEM_PREFIX = '<div class="item">'
HTML_ITEM_SUFFIX = '</div>'

require 'simple-rss'
require 'open-uri'
require 'right_aws'





# Generating HTML with images from Amazon AWS
def generate_html()
  html = ""
  
  s3 = RightAws::S3.new(S3_ID, S3_KEY)
  bucket = s3.bucket(S3_BUCKET)
  
  bucket.keys.each do |key|
    if key.full_name.include?(IMG_DIR)
      html += HTML_ITEM_PREFIX + '<img src="' + S3_PUBLIC + key.full_name + '" />' + HTML_ITEM_SUFFIX
    end
  end
  
  File.open(HTML_FILE, 'a') { |f| f.write(html) }  
end


# Uploading images to Amazon AWS S3
def upload_images(dir)
  s3 = RightAws::S3.new(S3_ID, S3_KEY)  
    
  pattern = File.join("**", dir, "*.png")
  files = Dir.glob(pattern)
  files.each do |f|
    puts "Uploading #{f}"
    s3.bucket(S3_BUCKET).put(f, File.open(f), {}, 'public-read')
  end
end


# Processing images
# - creating thumbnails and resizing screenhots
def process_images(dir)
  pattern = File.join("**", dir, "*.png")
  files = Dir.glob(pattern)
  files.each do |f|
    unless f.include?(IMG_THUMB) || f.include?(IMG_FINAL)
      puts "Converting #{f}"
      f2 = f.gsub /.png/, ''
      # thumbs
      system "convert #{f} -resize #{IMG_THUMB_SIZE}^ -extent #{IMG_THUMB_SIZE} #{f2}#{IMG_THUMB}.png" unless File.exists?("#{f2}#{IMG_THUMB}.png")
      # final
      system "convert #{f} -resize #{IMG_SIZE} #{f2}#{IMG_FINAL}.png" unless File.exists?("#{f2}#{IMG_FINAL}.png")        
    end
  end
end


# Process feed
# - creates screenshots from a feed
# 
# - url: feed url
# - limit how many items to process (starts from 1, not from 0)
def process_feed(url, limit=200)
  rss = SimpleRSS.parse open(url)
  rss.items.each_with_index do |item, index|
    puts "Parsing #{item.title}"
    screenshoot(item.link, to_filename(item.title, IMG_FILENAME_SIZE))
    puts "... donez"
    puts ""
    break if index == limit-1
  end  
end


# Create screenshoot
# - if the screenshot already exists it will be skipped
#
# - url: the address to screenshot
# - filename: where to save the screenshoot
def screenshoot(url, filename)
  unless File.exists?("#{IMG_DIR}/#{filename}.png")
    system "python webkit2png.py -t 10 -o #{IMG_DIR}/#{filename}.png #{url} "
  else 
    puts "Already screenshoted: #{IMG_DIR}/#{filename}.png"
  end
end



# Sanitize feed title for image file name
# - size => the lenght of filename in chars
# - filename is downcased 
def to_filename(filename, size)
  filename.gsub! /^.*(\\|\/)/, ''
  filename.gsub!(/[^0-9A-Za-z.\-]/, '')  
  filename.downcase.slice! 0..size
end


#process_feed(RSS, 1)
#process_images(IMG_DIR)
#upload_images(IMG_DIR)
generate_html()

