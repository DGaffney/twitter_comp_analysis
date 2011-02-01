require File.expand_path(File.dirname(__FILE__))+'/models'
require File.expand_path(File.dirname(__FILE__))+'/utils'

require 'rubygems'
require 'json'
require 'open-uri'
require 'fastercsv'

def start_thinkers_search(term)
  puts "Starting to search for the term #{term}"
  # tweets = Tweet.all(:followers.lte => 50)
  tweets = Tweet.all
  FileUtils.mkdir_p("collections/#{term}")
  FasterCSV.open("collections/#{term}/#{term}.csv", "w") do |csv|
    tweets.each do |tweet|
      unless tweet['tweet'].include? "RT"
        if tweet['tweet'].include? term

          csv << [tweet['screen_name'], tweet['followers'], tweet['tweet'], tweet['created_at'], download(tweet['screen_name'],tweet['profile_image'],term) ]

        end
      end
    end
  end
end

def download(screenname, profile_image, term)
  begin
    image_url = profile_image.gsub("_normal", "")
    image_name = image_url.match(/([\w_]+).(\w\w\w)$/)
    file_path = "collections/#{term}/#{screenname}_#{image_name[1]}.#{image_name[2]}"
    unless File.exists?(file_path)
      File.open(file_path, 'w') do |output|
        begin
          open(image_url) do |input|
            output << input.read
          end
          puts "Downloaded profile image"
        rescue
          puts "Download image failed"
        end
      end
    end
    return file_path

  rescue
    return "Download Failed"
  end

end


start_thinkers_search(ARGV[0])