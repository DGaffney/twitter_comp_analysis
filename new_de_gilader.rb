require 'rubygems'
require 'dm-core'
require 'dm-validations'
`ls models`.split("\n").each {|model| require "models/#{model}"}
require 'utils'
require 'extensions/array'
DataMapper.finalize

all_my_bases = {"e" => "140kit_scratch_2", "t" => "140kit_scratch_1"}

class NewDeGilader
  
  HAT_WOBBLE = 100

  def initialize(username, password, hostname, database)
    DataMapper.setup(:default, "mysql://#{username}:#{password}@#{hostname}/#{database}")
  end

  def gilad_clean
    tweet_ids = DataMapper.repository(:default).adapter.select("select id from tweets where (in_reply_to_status_id is null or in_reply_to_status_id=0) and text like 'rt%' order by rand()") # or (tweets.screen_name=users.screen_name and users.followers_count=0)  << This will pull out users with zero follower counts
    tweet_id_groupings = tweet_ids.chunk(HAT_WOBBLE)
    threads = []
    tweet_id_groupings.each do |grouping|
      threads<<Thread.new{
        run_tweets(grouping)
      }
    end
    threads.collect{|x| x.join}
  end

  def run_tweets(tweet_ids)
    disallowed_user_keys = []
    disallowed_tweet_keys = ["id_str", "retweeted_status", "in_reply_to_user_id", "in_reply_to_status_id", "in_reply_to_screen_name"]
    tweet_ids.each do |tweet_id|
      tweet = Tweet.first(:id => tweet_id)
      tweet.twitter_id = tweet.link.scan(/statuses\%2F(.*)/).compact.flatten.first.to_i
      tweet.screen_name = tweet.author
      tweet.created_at = tweet.pubdate
      tweet_data,user_data = Utils.tweet_data(tweet.twitter_id) rescue nil
      if tweet_data && user_data
        user = User.first(:twitter_id => user_data["id"]) || User.new
        tweet_data.keys.each do |key|
          if tweet.methods.include?(key)
            if key=="id"
              tweet.send("twitter_id=", tweet_data[key])
            elsif key=="retweet_count"
              tweet.retweet_count = tweet_data[key].to_i
            else
              tweet.send("#{key}=", tweet_data[key]) if !disallowed_tweet_keys.include?(key)
            end
          end
          possible_retweeted_user = User.first(:screen_name => tweet_data["text"].strip.scan(/[rt:|rt|RT|RT:]\s*@(\w*)\W/).flatten.first)
          tweet.in_reply_to_user_id = tweet_data["retweeted_status"]["in_reply_to_user_id"] || tweet_data["retweeted_status"]&&tweet_data["retweeted_status"]["user"]&&tweet_data["retweeted_status"]["user"]["id"] || possible_retweeted_user&&possible_retweeted_user.id
          tweet.in_reply_to_status_id = tweet_data["retweeted_status"]["in_reply_to_status_id"] || tweet_data["retweeted_status"]&&tweet_data["retweeted_status"]["id"]
          tweet.in_reply_to_screen_name = tweet_data["retweeted_status"]["in_reply_to_screen_name"] || tweet_data["retweeted_status"]&&tweet_data["retweeted_status"]["user"]&&tweet_data["retweeted_status"]["user"]["screen_name"] || possible_retweeted_user&&possible_retweeted_user.screen_name
        end
        if tweet.save
          puts "Tweet: #{tweet.author}"
        else
          puts "Tweet: #{tweet.author} [failed]"
          tweet.errors.each {|e| puts puts "  => #{e}" }
        end
        debugger
        user.screen_name = tweet.author
        user_data.keys.each do |key|
          if user.methods.include?(key)
            if key=="id"
              user.send("twitter_id=", user_data[key])
            else
              user.send("#{key}=", user_data[key]) if !disallowed_user_keys.include?(key)
            end
          end
        end
        if user.save
          puts "User: #{user.screen_name||user.username}"
        else
          puts "User: #{user.screen_name||user.username} [failed]"
          user.errors.each {|e| puts puts "  => #{e}" }
        end
      else
        puts "404: #{tweet.link.gsub('%2F', '/').gsub('%3A', ':')}"
        Utils.wait_until_not_rate_limited if Utils.rate_limited?
      end
    end
  end
end

if ARGV.empty?
  puts "## IRB MODE ##"
  db = all_my_bases["tunisia"]
  1.upto(10000) do |x|
    gg = NewDeGilader.new('gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', db)
  end
else
  db = all_my_bases[ARGV[0]]
  1.upto(10000) do |x|
    gg = NewDeGilader.new('gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', db)
    gg.gilad_clean
  end
end
