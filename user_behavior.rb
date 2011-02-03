require 'utils'

module UserBehavior
  
  @egypt_keys = %w{ egypt mubarak jan25 tahrir }
  @tunisia_keys = %w{ sidibouzid tunisia jasmine }
  
  def self.generate_user_behavior(user_hash,references=nil)
    terms = $db_rightful_name=="egypt" ? @egypt_keys : @tunisia_keys
    count = 200 # max is 200
    tweets = Utils.statuses(user_hash[:screen_name], count, true)
    return user_stats if tweets.nil?
    puts "User has less than #{count} tweets." if tweets.length < count
    counts = {:specific => {:user_gets_retweeted => 0, :user_retweets => 0, :total => 0},
              :nonspecific => {:user_gets_retweeted => 0, :user_retweets => 0, :total => 0}}
    for tweet in tweets
      # tweet is either a retweet or original content
      # original content is either shared or not shared
      context = tweet["text"].scan(/(#{terms.join('|')})/).empty? ? :nonspecific : :specific\
      counts[context][:total] += 1
      if tweet["retweeted_status"].nil?
        if tweet["retweet_count"].to_i > 0
          counts[context][:user_gets_retweeted] += 1
        end
      else counts[context][:user_retweets] += 1
      end
    end
    # puts counts.inspect
    total_tweets = tweets.length.to_f
    days = (Time.now-Time.parse(tweets.last['created_at']))/60/60/24
    new_stats = {:average_tweets_per_day => (total_tweets/days)}
    for context in [:specific, :nonspecific]
      new_stats[context] = {:percent_user_retweets => (counts[context][:user_retweets]/counts[context][:total].to_f),
        :percent_user_gets_retweeted => (counts[context][:user_gets_retweeted]/counts[context][:total].to_f),
        :percent_original_tweets => 1-(counts[context][:user_retweets]/counts[context][:total].to_f),
        :total => counts[context][:total] }
    end
    return user_hash.merge(new_stats)
  end
end