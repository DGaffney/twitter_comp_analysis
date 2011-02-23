class TweetsChosenThread < ActiveRecord::Base
  require 'open-uri'
  def children
    unambiguous_children = ActiveRecord::Base.connection.execute("SELECT tweets_chosen_threads.* FROM tweets_chosen_threads INNER JOIN edges ON edges.start_node = tweets_chosen_threads.author WHERE edges.style = 'retweet' AND edges.end_node = '#{self.author}' AND tweets_chosen_threads.thread_id=#{self.thread_id} and tweets_chosen_threads.pubdate > '#{self.pubdate.strftime("%Y-%m-%d %H:%M:%S")}'").all_hashes.collect{|x| TweetsChosenThread.new(x)}
    ambiguous_children = ActiveRecord::Base.connection.execute("SELECT tweets_chosen_threads.* FROM tweets_chosen_threads INNER JOIN tweets ON tweets.twitter_id = tweets_chosen_threads.twitter_id WHERE tweets_chosen_threads.thread_id=#{self.thread_id} and tweets_chosen_threads.text = '#{TweetsChosenThread.all_parents(self)}#{self.text}' and tweets_chosen_threads.pubdate > '#{self.pubdate.strftime("%Y-%m-%d %H:%M:%S")}'").all_hashes.collect{|x| TweetsChosenThread.new(x)}
    return {"unambiguous" => unambiguous_children, "ambiguous" => ambiguous_children}
  end
  
  def in_reply_to_status_id
    Tweet.find_by_twitter_id(self.twitter_id).in_reply_to_status_id
  end
  
  def self.return_child_js(tct, ambiguity)
    result = {}
    result["id"] = tct.twitter_id.to_s
    result["name"] = tct.author
    result["data"] = {}
    if !ambiguity.nil?
      result["data"]["ambiguity"] = ambiguity == "ambiguous"
    end
    children_data = []
    tct.children.each_pair do |ambiguity, children_objs|
      children_objs.each do |child|
        children_data << TweetsChosenThread.return_child_js(child, ambiguity)
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
      condition = tct.class == Array ? (tweet.first["in_reply_to_status_id"] != 0 && !tweet.first["in_reply_to_status_id"].nil?) : (tweet.in_reply_to_status_id != 0 && !tweet.in_reply_to_status_id.nil?)
      if condition
        parent_id = tct.class == Array ? tweet.first["in_reply_to_status_id"] : tweet.in_reply_to_status_id
        parent_statement << TweetsChosenThread.all_parents(Tweet.find_by_twitter_id(parent_id)||TweetsChosenThread.tweet_data(parent_id))
      end
      return parent_statement.reverse.to_s
    else return ""
    end
  end
  
  def self.tweet_data(twitter_id)
    data = self.safe_pull("http://api.twitter.com/1/statuses/show/#{twitter_id}.json")
    if data
      user = data.delete("user")
    return data, user
      else return {},{}
    end
  end
  
  def self.safe_pull(url, retries=3)
    begin
      data = nil
      api_url = "http://api.twitter.com/1/account/rate_limit_status.json"
      json = JSON.parse(open(api_url).read) rescue nil
      if json
        puts "#{json["remaining_hits"]} hits left, next reset in #{Time.parse(json["reset_time"])-Time.now} seconds. Sleeping for #{(Time.parse(json["reset_time"])-Time.now).abs} seconds."
      #   sleep((Time.parse(json["reset_time"])-Time.now).abs/json["remaining_hits"].to_i)
      end
      1.upto(retries) {|i| data = JSON.parse(open(url).read) rescue nil; break if !data.nil? }
      return data
    rescue
      return nil
    end
  end
  
end
