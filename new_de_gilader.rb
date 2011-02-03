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


  def self.setup(username, password, hostname, database)
    DataMapper.setup(:default, "mysql://#{username}:#{password}@#{hostname}/#{database}")
    self.gilad_clean
  end

  def self.setup_users(username, password, hostname, database)
    DataMapper.setup(:default, "mysql://#{username}:#{password}@#{hostname}/#{database}")
    self.users_clean
  end

  def self.gilad_clean
    tweet_ids = DataMapper.repository(:default).adapter.select("select id from tweets where (in_reply_to_status_id is null or in_reply_to_status_id=0) and text like 'rt%' order by rand()") # or   << This will pull out users with zero follower counts
    $graph_id = Graph.first(:title => "retweets").id
    tweet_id_groupings = tweet_ids.chunk(HAT_WOBBLE)
    threads = []
    tweet_id_groupings.each do |grouping|
      threads<<Thread.new{
        self.run_tweets(grouping)
      }
    end
    threads.collect{|x| x.join}
  end

  def self.run_tweets(tweet_ids)
    disallowed_user_keys = []
    disallowed_tweet_keys = ["id_str", "retweeted_status", "in_reply_to_user_id", "in_reply_to_status_id", "in_reply_to_screen_name"]
    tweet_ids.each do |tweet_id|
      tweet = Tweet.first(:id => tweet_id)
      puts "Pulling data on #{tweet.author}..."
      tweet.twitter_id = tweet.link.scan(/statuses\%2F(.*)/).compact.flatten.first.to_i
      tweet.screen_name = tweet.author
      tweet.created_at = tweet.pubdate
      tweet_data,user_data = Utils.tweet_data(tweet.twitter_id) rescue nil
      if tweet_data && user_data
        puts "Data found for #{tweet.author}..."
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
        end
        possible_retweeted_user = User.first(:screen_name => tweet_data["text"].strip.scan(/[rt:|rt|RT|RT:]\s*@(\w*)\W/).flatten.first)
        tweet.in_reply_to_user_id = tweet_data["in_reply_to_user_id"] || tweet_data["retweeted_status"]&&tweet_data["retweeted_status"]["user"]&&tweet_data["retweeted_status"]["user"]["id"] || possible_retweeted_user&&possible_retweeted_user.id
        tweet.in_reply_to_status_id = tweet_data["in_reply_to_status_id"] || tweet_data["retweeted_status"]&&tweet_data["retweeted_status"]["id"]
        tweet.in_reply_to_screen_name = tweet_data["in_reply_to_screen_name"] || tweet_data["retweeted_status"]&&tweet_data["retweeted_status"]["user"]&&tweet_data["retweeted_status"]["user"]["screen_name"] || possible_retweeted_user&&possible_retweeted_user.screen_name
        if tweet.in_reply_to_user_id&&tweet.in_reply_to_status_id&&tweet.in_reply_to_screen_name
          edge = Edge.new
          edge.start_node = tweet.in_reply_to_screen_name
          edge.end_node = tweet.author
          edge.edge_id = tweet.twitter_id
          edge.style = "retweet"
          edge.graph_id = $graph_id
          edge.save!
        end
        puts "author: #{tweet.author} irtui: #{tweet.in_reply_to_user_id} irtsi: #{tweet.in_reply_to_status_id} irtsn: #{tweet.in_reply_to_screen_name}"
        puts "Tweet Saved for #{tweet.author}: #{tweet.save!.inspect} (#{tweet.twitter_id})"
        if tweet.save!
          puts "Tweet: #{tweet.author}"
        else
          puts "Tweet: #{tweet.author} [failed]"
          tweet.errors.each {|e| puts puts "  => #{e}" }
        end
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
  
  def self.users_clean
    screen_names = DataMapper.repository(:default).adapter.select("select author from tweets,users where (tweets.author=users.screen_name and users.followers_count=0)")
    screen_name_groupings = screen_names.chunk(HAT_WOBBLE)
    threads = []
    screen_name_groupings.each do |grouping|
      threads<<Thread.new{
        self.run_users(grouping)
      }
    end
    threads.collect{|x| x.join}
  end
  
  def self.run_users(screen_names)
    disallowed_keys = []
    screen_names.each do |screen_name|
      user_data = Utils.user rescue nil
      if user_data
        user = User.first(:screen_name => screen_name) || User.new
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
        puts "404: http://api.twitter.com/1/users/show.json?screen_name=#{screen_name}"
      end
    end
  end
end

if ARGV.empty?
  puts "## IRB MODE ##"
  db = all_my_bases["tunisia"]
  1.upto(10000) do |x|
    NewDeGilader.setup('gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', db)
  end
else
  db = all_my_bases[ARGV[0]]
  1.upto(10000) do |x|
    NewDeGilader.setup('gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', db)
  end
end
