require 'rubygems'
require 'json'
require 'open-uri'

module Utils
  def self.user_id(screen_name)
    return self.user(screen_name)['id'] rescue nil
  end

  def self.tweet_data(twitter_id)
    data = self.safe_pull("http://api.twitter.com/1/statuses/show/#{twitter_id}.json")
    if data
      user = data.delete("user")
    return data, user   
      else return {},{}
    end
  end

  def self.user(screen_name)
    JSON.parse(open("http://api.twitter.com/1/users/show.json?screen_name=#{screen_name}").read)
  end

  def self.twitter_status(screen_name)
    JSON.parse(open("http://api.twitter.com/1/statuses/show/#{twitter_id}.json").read)
  end

  def self.screenname(user_id)
    return JSON.parse(open("http://api.twitter.com/1/users/show.json?user_id=#{user_id}").read)['screen_name'] rescue nil
  end
  
  def self.safe_pull(url, retries=3)
    data = nil
    api_url = "http://api.twitter.com/1/account/rate_limit_status.json"
    json = JSON.parse(open(api_url).read) rescue nil
    if json
      puts "#{json["remaining_hits"]} hits left, next reset in #{Time.parse(json["reset_time"])-Time.now} seconds. Sleeping for #{json["remaining_hits"].to_i/(Time.parse(json["reset_time"])-Time.now).abs} seconds."
      sleep(json["remaining_hits"].to_i/(Time.parse(json["reset_time"])-Time.now).abs)
    end
    1.upto(retries) {|i| data = JSON.parse(open(url).read) rescue nil; break if !data.nil? }
    return data
  end
  
  def self.rate_limited?
    api_url = "http://api.twitter.com/1/account/rate_limit_status.json"
    json = JSON.parse(open(api_url).read) rescue nil
    if json.nil? || json['remaining_hits'] <= 0
      # puts "RATE LIMITED!"
      return true
    else
      return false
    end
  end
  
  def self.wait_until_not_rate_limited
    puts "Waiting until we're not rate limited..."
    sleep(30) while self.rate_limited?
    puts "Yay! We are no longer rate limited!"
  end
  
  def self.follows?(user_a, user_b)
    bool = open("http://api.twitter.com/1/friendships/exists.json?user_a=#{user_a}&user_b=#{user_b}").read rescue nil
    return false if bool == "false"
    return true if bool == "true"
    return bool
  end

  def self.build_network(user_ids)
    network = {}
    for user_id in user_ids
      followers = self.get_followers_from_id(user_id)
      matched = followers & user_ids
      network[user_id] = matched
    end
    return network
  end

  def self.get_followers_from_id(user_id)
    api_url = "http://api.twitter.com/1/followers/ids.json?user_id=#{user_id}"
    ids = JSON.parse(open(api_url).read) rescue nil
    ids = JSON.parse(open(api_url).read) if ids.nil? rescue nil
    if ids.nil?
      puts "Couldn't get followers for #{user_id}."
      return []
    end
    ids.collect! {|id| id.to_i}
    puts "Found #{ids.length} followers for #{user_id}."
    return ids
  end
  
  def self.get_followers_from_screen_name(screen_name)
    api_url = "http://api.twitter.com/1/followers/ids.json?screen_name=#{screen_name}"
    ids = JSON.parse(open(api_url).read) rescue nil
    ids = JSON.parse(open(api_url).read) if ids.nil? rescue nil
    if ids.nil?
      puts "Couldn't get followers for #{screen_name}."
      return []
    end
    ids.collect! {|id| id.to_i}
    puts "Found #{ids.length} followers for #{screen_name}."
    return ids
  end
  
  def self.get_friends_from_id(user_id)
    api_url = "http://api.twitter.com/1/friends/ids.json?user_id=#{user_id}"
    ids = JSON.parse(open(api_url).read) rescue nil
    ids = JSON.parse(open(api_url).read) if ids.nil? rescue nil
    if ids.nil?
      puts "Couldn't get friends for #{user_id}."
      return []
    end
    ids.collect! {|id| id.to_i}
    puts "Found #{ids.length} friends for #{user_id}."
    return ids
  end
  

  # def self.statuses(screen_name, count=100, include_rts=false, page=1)
  #   api_url = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{screen_name}&count=#{count}&include_rts=#{include_rts}&page=#{page}"
  #   status_hash = []
  #   1.upto(4) {|i| status_hash = JSON.parse(open(api_url).read) rescue nil; break if !status_hash.nil? }
  #   return status_hash || []
  # end

  def self.statuses(screen_name, count=:all, include_rts=true)
    statuses = []
    if count == :all
      retries = 3
      1.upto(16) do |page|
        api_url = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{screen_name}&page=#{page}&count=200&include_rts=#{include_rts}&include_entities=1"
        new_statuses = []
        1.upto(retries) {|i| new_statuses = JSON.parse(open(api_url).read) rescue nil; break if !new_statuses.nil? }
        break if new_statuses.nil? || new_statuses.empty? || (Time.parse(new_statuses.last["created_at"]) < Time.parse("2011-01-01 01:01:01"))
        puts "Found #{new_statuses.length} statuses from page #{page}."
        statuses += new_statuses
      end
      statuses.uniq!
    else
      api_url = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{screen_name}&count=#{count}&include_rts=#{include_rts}&include_entities=1"
      statuses = JSON.parse(open(api_url).read) rescue nil
    end
    return statuses
  end

  def self.save_graphml(network)
    graph_name = "#{Time.now.strftime("%Y-%m-%d_%H-%M")}"
    Dir.mkdir("graphs") if !File.directory?("graphs")
    puts "Writing to graphs/#{graph_name}.graphml"
    file = File.new("graphs/#{graph_name}.graphml", "w")
    file.write %(<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
    http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
  <graph id="#{graph_name}" edgedefault="directed">
)
    file.write network.keys.collect {|id| "<node id=\"#{id}\"/>"}.join("\n    ")+"\n"
    network.each do |followed, followers|
      for follower in followers
        file.write "    <edge source=\"#{follower}\" target=\"#{followed}\"/>\n"
      end
    end
    file.write "  </graph>\n"
    file.write "</graphml>"
    file.close
    puts "Saved graphs/#{graph_name}.graphml"
    return
  end
  
  def self.save_graphml_from_graph(graph_id)
    edges = Edge.all(:graph_id => graph_id, :fields => ['start_node', 'end_node'])
    self.save_graphml_from_edges(edges)
  end
  
  def self.save_graphml_from_edges(edges)
    graph_name = "#{Time.now.strftime("%Y-%m-%d_%H-%M")}"
    Dir.mkdir("graphs") if !File.directory?("graphs")
    puts "Writing to graphs/#{graph_name}.graphml"
    file = File.new("graphs/#{graph_name}.graphml", "w")
    file.write %(<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
    http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
  <graph id="#{graph_name}" edgedefault="directed">
)
    file.write edges.collect {|e| [e.start_node, e.end_node] }.flatten.uniq.collect {|n| "<node id=\"#{n}\"/>"}.join("\n    ")+"\n"
    for edge in edges
      for follower in followers
        file.write "    <edge source=\"#{edge.start_node}\" target=\"#{edge.end_node}\"/>\n"
      end
    end
    file.write "  </graph>\n"
    file.write "</graphml>"
    file.close
    puts "Saved graphs/#{graph_name}.graphml"
    return
  end
  
end
