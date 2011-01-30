class NewDeGilader
  require 'rubygems'
  require 'dm-core'
  require 'dm-mysql-adapter'
  `ls models`.split("\n").each {|model| require "models/#{model}"}
  require 'utils.rb'
  
  HAT_WOBBLE = 10
  FLAHRGUNNSTOW = 1000.0

  def initialize_connect
    DataMapper.finalize
    DataMapper.setup(:default, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
    DataMapper.setup(:tunisia, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
    DataMapper.setup(:iran, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch')
    DataMapper.setup(:egypt, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')
  end
  
  def run_clean(database)
    database = DataMapper.repository(database)
    self.send(database.to_s+"_clean", database)
  end
  
  def iran_clean(database)
    database do
      disallowed_user_keys = ["friends_count", "followers_count"]
      disallowed_tweet_keys = ["id_str"]
      tweet_ids = database.adapter.select("SELECT id FROM tweets where source is NULL")
      tweet_id_groupings =  tweet_ids.chunk(tweet_ids.length/FLAHRGUNNSTOW)
      current_threads = 0 
      while !tweet_id_groupings.empty?
        tweet_id_groupings.each do |grouping|
          if current_threads < HAT_WOBBLE
            Thread.new{|x|run_tweets(database,grouping);tweet_id_groupings=tweet_id_groupings-[grouping]}
          end
        end
      end
    end
  end
  
  def tunisia_clean(database)
    database do
      disallowed_user_keys = ["friends_count", "followers_count"]
      disallowed_tweet_keys = ["id_str"]
      tweet_ids = database.adapter.select("SELECT id FROM tweets where source is NULL")
      tweet_id_groupings =  tweet_ids.chunk(tweet_ids.length/FLAHRGUNNSTOW)
      current_threads = 0 
      while !tweet_id_groupings.empty?
        tweet_id_groupings.each do |grouping|
          if current_threads < HAT_WOBBLE
            Thread.new{|x|run_tweets(database,grouping);tweet_id_groupings=tweet_id_groupings-[grouping]}
          end
        end
      end
    end
  end
  
  def egypt_clean(database)
    database do
      disallowed_user_keys = ["friends_count", "followers_count"]
      disallowed_tweet_keys = ["id_str"]
      tweet_ids = database.adapter.select("SELECT id FROM tweets where source is NULL")
      tweet_id_groupings =  tweet_ids.chunk(tweet_ids.length/FLAHRGUNNSTOW)
      current_threads = 0 
      while !tweet_id_groupings.empty?
        tweet_id_groupings.each do |grouping|
          if current_threads < HAT_WOBBLE
            Thread.new{|x|run_tweets(database,grouping);tweet_id_groupings=tweet_id_groupings-[grouping]}
          end
        end
      end
    end
  end
  
  def run_tweets(database,tweet_ids)
    tweet_ids.each do |tweet_id|
      tweet = Tweet.first(:id => tweet_id)
      if !tweet.source
        puts "Processing tweet from #{tweet.author}"
        tweet.twitter_id = tweet.link.scan(/statuses\%2F(.*)/).compact.flatten.first.to_i
        tweet.screen_name = tweet.author
        tweet.created_at = tweet.pubdate
        tweet_data,user_data = Utils.tweet_data(tweet.twitter_id) rescue nil
        if tweet_data && user_data
          user = User.first({:twitter_id => user_data["id"]}) || User.new
          tweet_data.keys.each do |key|
            if tweet.methods.include?(key)
              if key=="id"
                tweet.send("twitter_id=", tweet_data[key])
              else
                tweet.send("#{key}=", tweet_data[key]) if !disallowed_tweet_keys.include?(key)
              end
            end
          end
          tweet.save
          if user.new?
            user.screen_name = tweet.author
            puts "Saving user #{user.screen_name||user.username}"
            user_data.keys.each do |key|
              if user.methods.include?(key)
                if key=="id"
                  user.send("twitter_id=", user_data[key])
                else
                  user.send("#{key}=", user_data[key]) if !disallowed_user_keys.include?(key)
                end
              end
            end
            user.save
            puts "Saved user #{user.screen_name}"
          end
        end
      end
    end
  end
end