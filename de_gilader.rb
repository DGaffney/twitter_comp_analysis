require 'rubygems'
require 'dm-core'
`ls models`.split("\n").each {|model| require "models/#{model}"}
require 'utils.rb'
DataMapper.finalize
DataMapper.setup(:default, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
DataMapper.setup(:tunisia, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
DataMapper.setup(:iran, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch')
DataMapper.setup(:egypt, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')

def old_shit
  DataMapper.repository(:egypt) do 
    Tweet.all.each do |tweet|
      puts "WOO"
      user = DataMapper.repository(:egypt){User.new}
      user.screen_name = tweet.screen_name
      user.name = tweet.realname
    end
  end

  DataMapper.repository(:tunisia) do 
    Tweet.all.each do |tweet|
      puts "WOO"
      if !User.get(:screen_name => tweet.screen_name)
        # tweet.twitter_id = tweet.link.scan(/statuses\%2F(.*)/).compact.flatten.first.to_i
        # tweet.screen_name = tweet.author
        # tweet.created_at = tweet.pubdate
        # tweet.save
        user = DataMapper.repository(:tunisia){User.new}
        user.screen_name = tweet.screen_name
        user.name = tweet.realname
      end
    end
  end

  DataMapper.repository(:iran) do 
    Tweet.all.each do |tweet|
      puts "WOO"
      user = tweet.user
      user.screen_name = user.username
      user.save
      tweet.screen_name = user.screen_name
      tweet.save
    end
  end
end
def iran_clean
  DataMapper.repository(:iran) do
    disallowed_keys = ["friends_count", "followers_count"]
    User.all.each do |user|
      puts "Saving user #{user.screen_name||user.username}"
      user.screen_name = user.username
      user_data = Utils.user(user.screen_name) rescue nil
      if user_data
        user_data.keys.each do |key|
          if user.methods.include?(key)
            if key=="id"
              user.send("twitter_id=", user_data[key])
            else
              user.send("#{key}=", user_data[key]) if !disallowed_keys.include?(key)
            end
          end
        end
        user.save
        puts "Saved user #{user.screen_name}"
      end
    end
  end
end

def tunisia_clean
  DataMapper.repository(:tunisia) do
    disallowed_user_keys = ["friends_count", "followers_count"]
    disallowed_tweet_keys = ["id_str"]
    tweet_ids = DataMapper.repository(:tunisia).adapter.select("SELECT id FROM tweets where source is NULL")
    tweet_ids.each do |tweet_id|
      tweet = Tweet.first(:id => tweet_id)
      if !tweet.source
        puts "Processing tweet from #{tweet.author}"
        tweet.twitter_id = tweet.link.scan(/statuses\%2F(.*)/).compact.flatten.first.to_i
        tweet.screen_name = tweet.author
        tweet.created_at = tweet.pubdate
        user = User.first({:screen_name => tweet.author}) || User.new
        tweet_data,user_data = Utils.tweet_data(tweet.twitter_id) rescue nil
        if tweet_data
          tweet_data.each_key do |key|
            if tweet.methods.include?(key)
              if key=="id"
                tweet.send("twitter_id=", tweet_data[key])
              else
                tweet.send("#{key}=", tweet_data[key]) if !disallowed_tweet_keys.include?(key)
              end
            end
          end
        end
        tweet.save
        if user_data && user.new?
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

def egypt_clean
  DataMapper.repository(:egypt) do
    disallowed_user_keys = ["friends_count", "followers_count"]
    disallowed_tweet_keys = ["id_str"]
    tweet_ids = DataMapper.repository(:egypt).adapter.select("SELECT id FROM tweets where source is NULL")
    tweet_ids.each do |tweet_id|
      tweet = Tweet.first(:id => tweet_id)
      if !tweet.source
        puts "Processing tweet from #{tweet.author}"
        tweet.twitter_id = tweet.link.scan(/statuses\%2F(.*)/).compact.flatten.first.to_i
        tweet.screen_name = tweet.author
        tweet.created_at = tweet.pubdate
        user = User.first({:screen_name => tweet.author}) || User.new
        tweet_data,user_data = Utils.tweet_data(tweet.twitter_id) rescue nil
        if tweet_data
          tweet_data.keys.each do |key|
            if tweet.methods.include?(key)
              if key=="id"
                tweet.send("twitter_id=", tweet_data[key])
              else
                tweet.send("#{key}=", tweet_data[key]) if !disallowed_tweet_keys.include?(key)
              end
            end
          end
        end
        tweet.save
        if user_data && user.new?
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
          debugger
          user.save
          puts "Saved user #{user.screen_name}"
        end
      end
    end
  end
end
