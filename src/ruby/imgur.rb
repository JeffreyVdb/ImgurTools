require 'json/ext'
require 'net/http'
require 'optparse'
require 'uri'
require 'base64'

if $*.length < 1
  puts "Invalid arguments"
  raise "Invalid arguments supplied! Please supply a filename or directory to upload"
end

img = Base64.encode64 File.binread(ARGV[0])

UPLOAD_URL = "http://api.imgur.com/2/upload.json"
pathway = URI.parse(UPLOAD_URL)

# You MUST replace this with your developer key! 
KEY = "your developer key"

params = Net::HTTP::Post.new(pathway.path)
params.set_form_data({'key' => KEY, 'image' => img, 'type' => 'base64','name' => ARGV[0] })

res = Net::HTTP.start(pathway.host, pathway.port) {|http| http.request(params) }

details = JSON.parse(res.body)

puts details["upload"]['links']['imgur_page']
