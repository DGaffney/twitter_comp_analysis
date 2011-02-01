require 'rubygems'
require 'json'
require 'open-uri'

module Utils
  def self.user_id(screen_name)
    return self.user(screen_name)['id'] rescue nil
  end

  def self.tweet_data(twitter_id)
    puts "http://api.twitter.com/1/statuses/show/#{twitter_id}.json"
    data = JSON.parse(open("http://api.twitter.com/1/statuses/show/#{twitter_id}.json").read)
    debugger
    user = data.delete("user")
    return data, user   
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

# 
# 
# def followers_following_counts(screenname)
#   json = JSON.parse(open("http://api.twitter.com/1/users/show.json?screen_name=#{screenname}").read) rescue {}
#   return json["followers_count"], json["friends_count"]
# end
# 
# def tweets_per_day_and_followers_count(user_id, count=100)
#   statuses, followers_count = get_statuses_and_followers_count(user_id, count)
#   return if statuses.nil? || statuses.empty?
#   days = (Time.now-Time.parse(statuses.last['created_at']))/60/60/24
#   return (statuses.length.to_f/days), followers_count
# end
# 
# def tweets_per_day(statuses)
#   return nil if statuses.nil? || statuses.empty?
#   days = (Time.now-Time.parse(statuses.last['created_at']))/60/60/24
#   return statuses.length.to_f/days
# end
# 
# def statuses_followers_screenname(user_id, count=100)
#   api_url = "http://api.twitter.com/1/statuses/user_timeline.json?user_id=#{user_id}&count=#{count}"
#   statuses = JSON.parse(open(api_url).read) rescue nil
#   return nil, nil, nil if statuses.nil? || statuses.empty?
#   followers_count = statuses.first["user"]["followers_count"]
#   screenname = statuses.first["user"]["screen_name"]
#   return statuses, followers_count, screenname
# end
# 
# def avg_followers(cluster)
#   followers_counts = cluster.values.collect {|u| u[:followers_count]}
#   sum = followers_counts.inject(0) { |s,v| s += v }
#   return sum/followers_counts.length
# end
# 
# def active_cluster_with_avg_followers_count(initial_screenname, cluster_size, avg_followers, min_tpd=1.0)
#   
#   # cluster = { 123 => {:followers => [456, 789], :tpd => 1.2425, :followers_count => 346, :screenname => "LilHawtie1246999999"},
#   #             345 => {:followers => [123], :tpd => 2.5643, :followers_count => 1643, :screenname => "YaDingus"} }
#   
#   cluster = {}
#   
#   # initial user:
#   initial_user = user_id(initial_screenname)
#   cluster[initial_user] = {}
#   initial_statuses, cluster[initial_user][:followers_count], cluster[initial_user][:screenname] = statuses_followers_screenname(initial_user)
#   cluster[initial_user][:tpd] = tweets_per_day(initial_statuses)
#   
#   while cluster.length < cluster_size
#     # choose a random user from set
#     user_id = cluster.keys[rand(cluster.length)]
#     # for that user, get followers
#     all_followers = get_followers_from_id(user_id).shuffle
#     # for followers get random number of followers
#     number_to_fetch = 5
#     count = 0
#     for follower in all_followers
#       break if count >= number_to_fetch
#       if !cluster.has_key?(follower)
#         statuses, followers_count, screenname = statuses_followers_screenname(follower)
#         if !statuses.nil?
#           tpd = tweets_per_day(statuses)
#           # add if meets criteria
#           if tpd > min_tpd
#             current_avg_followers = avg_followers(cluster)
#             if (current_avg_followers > avg_followers && followers_count <= avg_followers) || (current_avg_followers <= avg_followers && followers_count >= avg_followers)
#               cluster[follower] = {:tpd => tpd, :followers_count => followers_count, :screenname => screenname}
#               puts "Cluster Size: #{cluster.size}"
#               puts "Average Followers Count: #{avg_followers(cluster)}"
#               count += 1
#             end
#           end
#         end
#       end
#     end
#     # cluster.merge!(followers)
#     # puts "Cluster Size: #{cluster.size}"
#     # puts "Average Followers Count: #{avg_followers(cluster)}"
#   end
#   return cluster
# end
# 
# def active_cluster(screenname, cluster_size, min_tpd=1.0)
#   cluster = active_followers_set(screenname, rand(8)+3, min_tpd)
#   cluster << user_id(screenname)
#   while cluster.length < cluster_size
#     user_id = cluster[rand(cluster.length)]
#     followers = active_followers_set_from_id(user_id, rand(8)+3, min_tpd)
#     puts "Current cluster: #{cluster.sort.inspect}"
#     puts "#{user_id}'s set: #{followers.sort.inspect}"
#     cluster = cluster|followers
#     puts "New cluster: #{cluster.sort.inspect}"
#   end
#   return cluster
# end
# 
# def active_followers_set(screenname, max=10, min_tpd=1.0)
#   set = []
#   puts "Set of #{max} followers of #{screenname} that tweet more than #{min_tpd} times a day:"
#   for follower in get_followers(screenname).shuffle
#     set << follower if active?(follower, min_tpd)
#     break if set.length >= max
#   end
#   return set
# end
# 
# def active_followers_set_from_id(user_id, max=10, min_tpd=1.0)
#   set = []
#   puts "Set of #{max} followers of User #{user_id} that tweet more than #{min_tpd} times a day:"
#   for follower in get_followers_from_id(user_id).shuffle
#     set << follower if active?(follower, min_tpd)
#     break if set.length >= max
#   end
#   return set
# end
# 
# def active_followers(screenname, min_tpd=1.0)
#   puts "Followers of #{screenname} that tweet more than #{min_tpd} times a day:"
#   active_in(get_followers(screenname), min_tpd)
# end
# 
# def active_in(user_ids, min_tpd=1.0)
#   for user_id in user_ids
#     print "#{user_id} " if active?(user_id, min_tpd)
#   end
# end
# 
# def follows?(user, follower)
#   expand(follower)
#   return get_followers(user).include? 
# end
# 
# # def tweets_per_day(user_id, count=100)
# #   statuses = get_statuses(user_id, count)
# #   return if statuses.nil? || statuses.empty?
# #   days = (Time.now-Time.parse(statuses.last['created_at']))/60/60/24
# #   return statuses.length.to_f/days
# # end
# 
# def active?(user_id, min_tpd=1.0, count=100)
#   tpd = tweets_per_day(user_id, count)
#   return false if tpd.nil?
#   return min_tpd <= tpd ? true : false
# end
# 
# def get_statuses(user_id, count=100)
#   api_url = "http://api.twitter.com/1/statuses/user_timeline.json?user_id=#{user_id}&trim_user=1&count=#{count}"
#   statuses = JSON.parse(open(api_url).read) rescue nil
#   return statuses
# end
# 
# def get_followers(screenname)
#   api_url = "http://api.twitter.com/1/followers/ids.json?screen_name=#{screenname}"
#   ids = JSON.parse(open(api_url).read)
#   ids = ids.collect {|id| id.to_i}
#   puts "Found #{ids.length} followers."
#   return ids
# end
# 
# def rate_limited?
  # api_url = "http://api.twitter.com/1/account/rate_limit_status.json"
  # json = JSON.parse(open(api_url).read) rescue nil
#   if json.nil? || json['remaining_hits'] <= 0
#     puts "RATE LIMITED!"
#     return true
#   else
#     return false
#   end
# end
# 
# def to_graphml(network, graph_id="cats")
#   nodes = network.keys.collect {|id| "<node id=\"#{id}\"/>"}.join("\n    ")
#   edges = ""
#   network.each do |followed, followers|
#     for follower in followers
#       edges += "\n    <edge source=\"#{follower}\" target=\"#{followed}\"/>"
#     end
#   end
#   return %(
# <?xml version="1.0" encoding="UTF-8"?>
# <graphml xmlns="http://graphml.graphdrawing.org/xmlns"  
#   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#   xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
#     http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
# <graph id="#{graph_id}" edgedefault="directed">
#   #{nodes}
#   #{edges}
# </graph>
# </graphml>)
# end
# 
# def print_graphml(network, graph_id="cats")
#   puts %(
# <?xml version="1.0" encoding="UTF-8"?>
# <graphml xmlns="http://graphml.graphdrawing.org/xmlns"  
#   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
#   xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
#     http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
# <graph id="#{graph_id}" edgedefault="directed">)
#   puts network.keys.collect {|id| "<node id=\"#{id}\"/>"}.join("\n    ")
#   network.each do |followed, followers|
#     for follower in followers
#       puts "    <edge source=\"#{follower}\" target=\"#{followed}\"/>"
#     end
#   end
#   puts "  </graph>"
#   puts "</graphml>"
#   return
# end