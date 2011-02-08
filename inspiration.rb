# inspiration.rb
# - fetching an RSS feed and create screenshots for feed item urls
# - upload images to Amazon AWS S3
# - create a HTML file with these images



# RSS
# 
# the feed 
RSS = 'http://feeds.delicious.com/v2/rss/csbartus/inspiration?count=100'

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

# creating screenshot timeout in seconds
IMG_TIMEOUT = 20


# Amazon S3
#
S3_ID = "AKIAIM4EGICY766JY2PA"
S3_KEY = "dJELxK7fO13rDAY0JLHa1TLSKDwNN21P1hy/dlvh"
S3_BUCKET = "webdesign-inspiration"
# right_aws doesn't get correctly the public link of the uploaded image
S3_PUBLIC = 'https://s3-eu-west-1.amazonaws.com/'



# HTML generation
#
HTML_FILE = "inspiration.html"
HTML_ITEM_PREFIX = '<div id="item">'
HTML_ITEM_SUFFIX = '</div>'
HTML_TOGGLE = '<div id="toggle"><span class="link large">Show large</span><span class="link original">Show original</span></div>'



require 'simple-rss'
require 'open-uri'
require 'right_aws'





# Generating HTML with images from Amazon AWS
# - includes only thumbnails to not slow down the page in case you have hundreds of images to show
# - the urls of larger images are included to manipulate later with Javascript
def generate_html()
  html = ""
  
  puts "Generating HTML ..."
  
  s3 = RightAws::S3.new(S3_ID, S3_KEY)
  bucket = s3.bucket(S3_BUCKET)
  
  thumb = ''
  original = ''
  large = ''
  bucket.keys.each do |key|
    if key.full_name.include?(IMG_DIR)
      if key.full_name.include?(IMG_THUMB)
        thumb = S3_PUBLIC + key.full_name        
      elsif key.full_name.include?(IMG_FINAL)
        large = S3_PUBLIC + key.full_name
      else
        original = S3_PUBLIC + key.full_name
      end      
      
      if thumb != '' && large != '' && original != ''
        html += HTML_ITEM_PREFIX 
        html += '<img class="thumbnail" src="' + thumb + '" rev="' + original + '" rel="' + large + '" />' 
        html += HTML_TOGGLE  + HTML_ITEM_SUFFIX        
        thumb = ''
        original = ''
        large = ''        
      end
    end
  end
  
  File.open(HTML_FILE, 'a') { |f| f.write(html) }  
end

def generate_html2()
  html = ""
  
  puts "Generating HTML ..."
  
  s3 = RightAws::S3.new(S3_ID, S3_KEY)
  bucket = s3.bucket(S3_BUCKET)
  
  bucket.keys.each do |key|
    if key.full_name.include?(IMG_DIR)
      if key.full_name.include?(IMG_THUMB)
        html += HTML_ITEM_PREFIX 
             + '<img class="' + klass + '" src="' + S3_PUBLIC + key.full_name + '" rev="' + 'rev' + '" rel="' + 'rel' +'" />' 
             + HTML_ITEM_SUFFIX
      elsif key.full_name.include?(IMG_FINAL)
        rev = S3_PUBLIC + key.full_name
      else
        rel = S3_PUBLIC + key.full_name
      end      
    end
  end
  
  File.open(HTML_FILE, 'a') { |f| f.write(html) }  
end


# Uploading images to Amazon AWS S3
# - The bucket must be initially created, creating here at command line requires too much setup data (region, logging, permissions etc)
def upload_images(dir)
  s3 = RightAws::S3.new(S3_ID, S3_KEY)  
  
  unless s3.bucket(S3_BUCKET).nil?   
    keys = s3.bucket(S3_BUCKET).keys.map {|k| k.to_s}
     
    pattern = File.join("**", dir, "*.png")
    files = Dir.glob(pattern)
    files.each do |f|
      unless keys.include? f
        puts "Uploading image #{f}"
        s3.bucket(S3_BUCKET).put(f, File.open(f), {}, 'public-read')
      else
        puts "Already uploaded: #{f}"
      end
    end
  else
    puts "The bucket must be initially created, creating it command line requires too much setup data (region, logging, permissions etc)"
  end
end


# Processing images
# - creating thumbnails and resizing screenhots
def process_images(dir)
  pattern = File.join("**", dir, "*.png")
  files = Dir.glob(pattern)
  files.each do |f|
    unless f.include?(IMG_THUMB) || f.include?(IMG_FINAL)
      puts "Converting image #{f}"
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
    puts "Parsing RSS item #{item.title}"
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
    system "python webkit2png.py -t #{IMG_TIMEOUT} -o #{IMG_DIR}/#{filename}.png #{url} "
  else 
    puts "Already screenshoted: #{IMG_DIR}/#{filename}.png"
  end
end


# Prepare the environment
def prepare()
  Dir.mkdir(IMG_DIR) unless Dir.exists?(IMG_DIR) 
end


# Sanitize feed title for image file name
# - size => the lenght of filename in chars
# - filename is downcased 
def to_filename(filename, size)
  filename.gsub! /^.*(\\|\/)/, ''
  filename.gsub!(/[^0-9A-Za-z.\-]/, '')  
  filename.downcase.slice! 0..size
end


prepare()
#process_feed(RSS, 110)
#process_images(IMG_DIR)
#upload_images(IMG_DIR)
generate_html()

