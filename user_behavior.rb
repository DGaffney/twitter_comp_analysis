require 'utils'

module UserBehavior
  
  @egypt_keys = %w{ egypt mubarak jan25 tahrir }
  @tunisia_keys = %w{ sidibouzid tunisia jasmine }
  
  def self.generate_user_behavior(user_hash ,references=nil)
    terms = $db_rightful_name=="egypt" ? @egypt_keys : @tunisia_keys
    # count = 200 # max is 200
    tweets = Utils.statuses(user_hash[:screen_name], :all, true)
    puts "Targuss Targuss"
    return user_hash if tweets.nil? || tweets.empty?
    # puts "User has less than #{count} tweets." if tweets.length < count
    counts = {:relevant_user_gets_retweeted => 0, :relevant_user_retweets => 0, :relevant_total => 0, :irrelevant_user_gets_retweeted => 0, :irrelevant_user_retweets => 0, :irrelevant_total => 0}
    for tweet in tweets
      # tweet is either a retweet or original content
      # original content is either shared or not shared
      context = tweet["text"].scan(/(#{terms.join('|')})/).empty? ? "irrelevant" : "relevant"
      counts["#{context}_total".to_sym] += 1
      if tweet["retweeted_status"].nil?
        if tweet["retweet_count"].to_i > 0
          counts["#{context}_user_gets_retweeted".to_sym] += 1
        end
      else counts["#{context}_user_retweets".to_sym] += 1
      end
    end
    # puts counts.inspect
    total_tweets = tweets.length.to_f
    days = (Time.now-Time.parse(tweets.last['created_at']))/60/60/24
    new_stats = {:average_tweets_per_day => (total_tweets/days)}
    for context in ["relevant", "irrelevant"]
      user_hash.merge!({"#{context}_percent_user_retweets".to_sym => (counts["#{context}_user_retweets".to_sym]/counts["#{context}_total".to_sym].to_f),
        "#{context}_percent_user_gets_retweeted".to_sym => (counts["#{context}_user_gets_retweeted".to_sym]/counts["#{context}_total".to_sym].to_f),
        "#{context}_percent_original_tweets".to_sym => 1-(counts["#{context}_user_retweets".to_sym]/counts["#{context}_total".to_sym].to_f),
        "#{context}_total".to_sym => counts["#{context}_total".to_sym] })
    end
    return user_hash
  end
end