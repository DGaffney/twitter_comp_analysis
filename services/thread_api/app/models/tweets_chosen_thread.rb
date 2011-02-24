class TweetsChosenThread < ActiveRecord::Base
  require 'open-uri'
    
  def in_reply_to_status_id
    Tweet.find_by_twitter_id(self.twitter_id).in_reply_to_status_id
  end
  
  def self.children(tct, thread_id)
    text = tct.class==Array ? tct.first["text"] : tct.text
    pubdate = tct.class==Array ? Time.parse(tct.first["created_at"]).strftime("%Y-%m-%d %H:%M:%S") : tct.pubdate.strftime("%Y-%m-%d %H:%M:%S") rescue (Time.now-1.year).strftime("%Y-%m-%d %H:%M:%S")
    ambiguous_children = ActiveRecord::Base.connection.execute("SELECT tweets_chosen_threads.* FROM tweets_chosen_threads INNER JOIN tweets ON tweets.twitter_id = tweets_chosen_threads.twitter_id WHERE tweets_chosen_threads.thread_id=#{thread_id} and tweets_chosen_threads.text = '#{TweetsChosenThread.all_parents(tct)}#{text.gsub("'", "\\'")}' and tweets_chosen_threads.pubdate > '#{pubdate}'").all_hashes.collect{|x| TweetsChosenThread.new(x)}
    return {"ambiguous" => ambiguous_children}
  end

  def self.return_child_js(tct, ambiguity, thread_id)
    #HERE, TCT is used loosely, could be anything, really, twitter data, a TCT, or a Tweet...
    result = {}
    result["id"] = tct.class==Array ? tct.first["id"] : tct.twitter_id.to_s
    result["name"] = tct.class==Array ? tct.last["screen_name"] : tct.author
    result["data"] = {}
    if !ambiguity.nil?
      result["data"]["ambiguity"] = ambiguity == "ambiguous"
    end
    children_data = []
    TweetsChosenThread.children(tct, thread_id).each_pair do |ambiguity, children_objs|
      children_objs.each do |child|
        children_data << TweetsChosenThread.return_child_js(child, ambiguity, thread_id)
      end
    end
    result["children"] = children_data
    return result
  end
  
  def self.all_parents(tct)
    if !tct.blank?
      parent_statement = []
      puts tct.inspect
      statement = tct.class == Array ? "RT @#{tct.last["screen_name"]}: " : "RT @#{tct.author}: "
      parent_statement << statement
      tweet_id = tct.class == Array ? tct.first["id"] : tct.twitter_id
      tweet = Tweet.find_by_twitter_id(tweet_id) || TweetsChosenThread.tweet_data(tweet_id)
      condition = nil
      if tweet.class == Array
        condition = tweet.first["in_reply_to_status_id"] != 0 && !tweet.first["in_reply_to_status_id"].nil? && (tweet.first["retweeted_status"]&&tweet.first["retweeted_status"]["id"].nil?) 
      else
        condition = tweet.in_reply_to_status_id != 0 && !tweet.in_reply_to_status_id.nil?
      end
      if condition
        parent_id = tct.class == Array ? (root.first["in_reply_to_status_id"] || root.first["retweeted_status"]&&root.first["retweeted_status"]["id"] || nil) : tweet.in_reply_to_status_id
        parent_statement << TweetsChosenThread.all_parents(Tweet.find_by_twitter_id(parent_id)||TweetsChosenThread.tweet_data(parent_id))
      end
      return parent_statement.reverse.to_s
    else return ""
    end
  end
  
  def self.tweet_data(twitter_id)
    data = TweetsChosenThread.safe_pull("http://api.twitter.com/1/statuses/show/#{twitter_id}.json")
    if data
      user = data.delete("user")
    return data, user
      else return {},{}
    end
  end
  
  
  def self.safe_pull(url, retries=3, caching=true)
    data = nil
    begin
      if caching
        data = Rails.cache.fetch(url.gsub("/", "%2F").gsub(":", "%3A")){TweetsChosenThread.url_pull(url, retries)}
      else
        data = TweetsChosenThread(url, retries)
      end
      return data
    rescue 
      return data
    end
  end
  
  def self.url_pull(url, retries)
    data = nil
    api_url = "http://api.twitter.com/1/account/rate_limit_status.json"
    json = JSON.parse(open(api_url).read) rescue nil
    if json
      puts "#{json["remaining_hits"]} hits left, next reset in #{Time.parse(json["reset_time"])-Time.now} seconds. Sleeping for #{(Time.parse(json["reset_time"])-Time.now).abs} seconds."
      sleep((Time.parse(json["reset_time"])-Time.now).abs/json["remaining_hits"].to_i)
    end
    1.upto(retries) {|i| data = JSON.parse(open(url).read) rescue nil; break if !data.nil? }
    return data
  end
  
end
