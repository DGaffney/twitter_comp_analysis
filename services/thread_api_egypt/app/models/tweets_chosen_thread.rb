class TweetsChosenThread < ActiveRecord::Base
  require 'open-uri'
    
  def in_reply_to_status_id
    Tweet.find_by_twitter_id(self.twitter_id).in_reply_to_status_id
  end
  
  def self.children(tct, thread_id)
    text = tct.class==Array ? tct.first["text"] : tct.text
    text = "" if text.nil?
    ambiguous_children = TweetsChosenThread.find(:all, :conditions => {:thread_id => thread_id})
    provenance = TweetsChosenThread.all_parents(tct).downcase.gsub("  ", " ").gsub(":", "")
    children = ambiguous_children.select{|x| x.text.downcase.gsub("  ", " ").gsub(":", "")=="#{provenance}#{text.downcase.gsub("  ", " ").gsub(":", "").gsub(/rt \@(\w*) rt \@$1/, "")}"}.compact
    return children
  end

  def self.return_child_js(tct, thread_id, included_ids=[])
    #HERE, TCT is used loosely, could be anything, really, twitter data, a TCT, or a Tweet...
    result = {}
    result["id"] = tct.class==Array ? tct.first["id"] : tct.twitter_id.to_s
    result["name"] = tct.class==Array ? tct.last["screen_name"] : tct.author
    result["data"] = {}
    children_data = []
    TweetsChosenThread.children(tct, thread_id).each do |child|
      if !included_ids.include?(child.twitter_id)
        included_ids << child.twitter_id
        children_data << TweetsChosenThread.return_child_js(child, thread_id, included_ids)
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
      return parent_statement.to_s
    else return ""
    end
  end
  
  def self.tweet_data(twitter_id)
    data = Tweet.find_by_twitter_id(twitter_id) || TweetsChosenThread.safe_pull("http://api.twitter.com/1/statuses/show/#{twitter_id}.json")
    if data && data!=1 && data.class==Hash
      user = data.delete("user")
      return data, user
    elsif !data.nil? && data!=1
      return data
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
    begin
      data = nil
      api_url = "http://api.twitter.com/1/account/rate_limit_status.json"
      json = JSON.parse(open(api_url).read) rescue nil
      if json
        puts "#{json["remaining_hits"]} hits left, next reset in #{Time.parse(json["reset_time"])-Time.now} seconds. Sleeping for #{(Time.parse(json["reset_time"])-Time.now).abs/json["remaining_hits"].to_i} seconds."
        sleep((Time.parse(json["reset_time"])-Time.now).abs/json["remaining_hits"].to_i)
      end
      1.upto(retries) {|i| raw = open(url).read rescue nil; data = JSON.parse(raw) rescue nil; break if !data.nil? }
    rescue Timeout::Error
      return data
    end
    return data
  end
  
end
