require 'rubygems'
require 'dm-core'
# require 'dm-validations'
`ls models`.split("\n").each {|model| require "models/#{model}"}
require 'utils'
require 'extensions/array'
DataMapper.finalize

all_my_bases = {"e" => "140kit_scratch_2", "t" => "140kit_scratch_1"}

class NewDeGilader
  
  HAT_WOBBLE = 10

  def initialize(username, password, hostname, database)
    DataMapper.setup(:default, "mysql://#{username}:#{password}@#{hostname}/#{database}")
    # DataMapper.setup(:default, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
    # DataMapper.setup(:tunisia, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
    # DataMapper.setup(:iran, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch')
    # DataMapper.setup(:egypt, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')
  end
  
  # def run_clean(database)
  #   if database==:iran
  #     devin_clean(database)
  #   else
  #     gilad_clean(database)
  #   end
  # end
  
  def gilad_clean
    # DataMapper.repository(database) do
      # tweet_ids = DataMapper.repository(database).adapter.select("SELECT id FROM tweets where source is NULL order by rand()")
      tweet_ids = DataMapper.repository(:default).adapter.select("SELECT id FROM tweets where source is NULL order by rand()")
      tweet_id_groupings =  tweet_ids.chunk(HAT_WOBBLE)
      threads = []
      tweet_id_groupings.each do |grouping|
        threads<<Thread.new{run_tweets(grouping)}
      end
      threads.collect{|x| x.join}
    # end
  end

  def run_tweets(tweet_ids)
    disallowed_user_keys = ["friends_count", "followers_count"]
    disallowed_tweet_keys = ["id_str"]
    tweet_ids.each do |tweet_id|
      # tweet = DataMapper.repository(database){Tweet.first(:id => tweet_id)}
      tweet = Tweet.first(:id => tweet_id)
      if !tweet.source
        # puts "Tweet: #{tweet.author}"
        tweet.twitter_id = tweet.link.scan(/statuses\%2F(.*)/).compact.flatten.first.to_i
        tweet.screen_name = tweet.author
        tweet.created_at = tweet.pubdate
        tweet_data,user_data = Utils.tweet_data(tweet.twitter_id) rescue nil
        if tweet_data && user_data
          # user = DataMapper.repository(database){User.first({:twitter_id => user_data["id"]})} || DataMapper.repository(database){User.new}
          user = User.first(:twitter_id => user_data["id"]) || User.new
          tweet_data.keys.each do |key|
            if tweet.methods.include?(key)
              if key=="id"
                tweet.send("twitter_id=", tweet_data[key])
              elsif key == "retweeted_status"
                tweet.in_reply_to_user_id = tweet_data[key]["in_reply_to_user_id"]
                tweet.in_reply_to_status_id = tweet_data[key]["in_reply_to_status_id"]
                tweet.in_reply_to_screen_name = tweet_data[key]["in_reply_to_screen_name"]
              elsif key=="retweet_count"
                tweet.retweet_count = tweet_data[key].to_i
              else
                tweet.send("#{key}=", tweet_data[key]) if !disallowed_tweet_keys.include?(key)
              end
            end
          end
          if tweet.save
            puts "Tweet: #{tweet.author}"
          else
            puts "Tweet: #{tweet.author} [failed]"
            tweet.errors.each {|e| puts puts "  => #{e}" }
          end
          if user.new?
            user.screen_name = tweet.author
            # puts "User: #{user.screen_name||user.username}"
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
            # puts "Saved user #{user.screen_name}"
          else puts "User: #{user.screen_name||user.username} [exists]"
          end
        else
          puts "404: #{tweet.link.gsub('%2F', '/').gsub('%3A', ':')}"
          Utils.wait_until_not_rate_limited if Utils.rate_limited?
        end
      end
    end
  end
end

db = all_my_bases[ARGV[0]]
gg = NewDeGilader.new('gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', db)
gg.gilad_clean
