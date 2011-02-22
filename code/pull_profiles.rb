require 'digest/sha1'

load "new_de_gilader.rb"
NewDeGilader.setup('gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', '140kit_scratch_1')
DataMapper.finalize
DataMapper.setup(:default, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')
DataMapper.setup(:tunisia, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
DataMapper.setup(:egypt, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')
limit = 1000
offset = 0

module PullProfiles
  def self.insert(model, records, database=:default)
    keys = nil
    sql_query = "insert ignore into #{model} (#{(keys=records.first.keys.collect{|x| x.to_s}).join(", ")}) VALUES "
    records.each do |record|
      row = keys.collect{|key| "?,"}
      sql_query+="(#{row.to_s.chop}), "
    end
    sql_query = sql_query.chop.chop
    gg = records.collect{|record| keys.collect{|key| record[key]}}.flatten
    DataMapper.repository(database).adapter.execute(sql_query, *gg)
  end

  def self.bulk_worker(model, conditions, query="", limit=1000)
    offset = 0
    last_id = DataMapper.repository(:default).adapter.select("select p_id from #{model} #{query} limit 1").first
    while last_id>offset+limit
      conditions[:limit] = limit
      conditions[:offset] = offset
      conditions[:order] = :p_id.desc
      objects = model.classify.constantize.all(conditions)
      orig_objects = Digest::SHA1.hexdigest(objects.to_s)
      puts objects
      yield objects
      new_objects = Digest::SHA1.hexdigest(objects.to_s)
      if new_objects!=orig_objects
        if objects.first.class!=Hash
          objects = objects.collect{|obj| obj.attributes}
        end
        insert(model, objects) 
      end
      if offset+1000>last_id
        limit = last_id-offset
      else
        offset+=1000
      end
    end
  end

  def self.collect_profile_data
    egypt_words = %w{ egypt mubarak jan25 tahrir }
    tunisia_words = %w{ sidibouzid tunisia jasmine }
    egypt = []
    tunisia = []
    users = []
    profiles = Profile.all.shuffle
    profiles.each do |profile|
      puts "Scanning #{profile.p_screen_name}..."
      tweets = Utils.statuses(profile.p_screen_name)
      tweets.each do |tweet|
        if !tweet["text"].scan(/(#{egypt_words.join('|')})/).empty? && !tweet["text"].scan(/(#{tunisia_words.join('|')})/).empty?
          egypt<<tweet
          tunisia<<tweet
        elsif !tweet["text"].scan(/(#{egypt_words.join('|')})/).empty?
          egypt<<tweet
        elsif !tweet["text"].scan(/(#{tunisia_words.join('|')})/).empty?
          tunisia<<tweet
        end
      end
      puts "Collected #{tweets.length} tweets... Currently at egypt: #{egypt.length}; tunisia: #{tunisia.length}; users: #{users.length}"
      users << PullProfiles.userfy_profile(profile)
      egypt = PullProfiles.generate_hashes(egypt);PullProfiles.insert("tweets", egypt, :egypt) if egypt.length>=1000
      egypt = [] if egypt.length>=1000
      tunisia = PullProfiles.generate_hashes(tunisia);PullProfiles.insert("tweets", tunisia, :tunisia) if tunisia.length>=1000
      tunisia = [] if tunisia.length>=1000
      PullProfiles.insert("users", users, :egypt) if users.length>=1000
      PullProfiles.insert("users", users, :tunisia) if users.length>=1000
      users = [] if users.length>=1000
    end
  end

  def self.userfy_profile(profile)
    profile = Profile.first(:p_id => profile.p_id)
    user = {}
    user["verified"] = profile.p_verified
    user["description"] = profile.p_description
    user["location"] = profile.p_location
    user["twitter_id"] = profile.p_twitter_id
    user["friends"] = profile.p_following_count
    user["time_zone"] = profile.p_time_zone
    user["screen_name"] = profile.p_screen_name
    user["followers"] = profile.p_followers
    user["lang"] = profile.p_lang
    user["updated_at"] = Time.now
    user["statuses_count"] = profile.p_statuses_count
    user["created_at"] = profile.p_created_at
    user["url"] = profile.p_url
    user["profile_image_url"] = profile.p_picture
    user["followers_count"] = profile.p_follower_count
    user["total_tweets"] = profile.p_statuses_count
    user["utc_offset"] = profile.p_utc_offset
    user["friends_count"] = profile.p_following_count
    user["name"] = profile.p_realname
    user["username"] = profile.p_screen_name
    user["geo_enabled"] = profile.p_geo_enabled
    user["account_birth"] = profile.p_created_at
    return user    
  end
  
  def self.uniq_edges(edges)
    puts "Uniquing returned data..."
    uniqued = []
    uniqued_ids = []
    edges.each do |edge|
      if !uniqued_ids.include?("#{edge["end_node"]}_#{edge["start_node"]}_#{edge["edge_id"]}")
        uniqued_ids << "#{edge["end_node"]}_#{edge["start_node"]}_#{edge["edge_id"]}"
        uniqued << edge
      end
    end
    puts "Uniqued data crunched from #{edges.length} => #{uniqued.length}..."
    return uniqued
  end

  def self.generate_hashes(datasheet, start_date=Time.parse("2011-01-01 01:01:01"), end_date=Time.now)
    tweets = []
    datasheet.each do |tweet_data|
      tweet = {}
      tweet["twitter_id"] = tweet_data["id"]
      tweet["twitter_id"] = tweet_data["id"]
      tweet["tweet_id"] = tweet_data["id"]
      tweet["text"] = tweet_data["text"]
      tweet["language"] = tweet_data["user"]&&tweet_data["user"]["lang"]||nil
      tweet["source"] = tweet_data["source"]
      tweet["user_id"] = tweet_data["user"]&&tweet_data["user"]["id"]||nil
      tweet["screen_name"] = tweet_data["user"]&&tweet_data["user"]["screen_name"]||nil
      tweet["username"] = tweet_data["user"]&&tweet_data["user"]["screen_name"]||nil
      tweet["location"] = tweet_data["user"]&&tweet_data["user"]["location"]||nil
      tweet["in_reply_to_status_id"] = tweet_data["in_reply_to_status_id"]
      tweet["in_reply_to_user_id"] = tweet_data["in_reply_to_user_id"]
      tweet["truncated"] = tweet_data["truncated"]
      tweet["in_reply_to_screen_name"] = tweet_data["in_reply_to_screen_name"]
      tweet["created_at"] = Time.parse(tweet_data["created_at"]).strftime("%Y-%m-%d %H:%M:%S %z")
      tweet["updated_at"] = Time.now.strftime("%Y-%m-%d %H:%M:%S %z")
      tweet["published"] = Time.parse(tweet_data["created_at"]).strftime("%Y-%m-%d %H:%M:%S %z")
      tweet["lat"] = tweet_data["geo"]&&tweet_data["geo"]["coordinates"]&&tweet_data["geo"]["coordinates"].first||nil
      tweet["lon"] = tweet_data["geo"]&&tweet_data["geo"]["coordinates"]&&tweet_data["geo"]["coordinates"].last||nil
      tweet["pubdate"] = Time.parse(tweet_data["created_at"]).strftime("%Y-%m-%d %H:%M:%S %z")
      tweet["author"] = tweet_data["user"]&&tweet_data["user"]["screen_name"]||nil
      tweet["realname"] = tweet_data["user"]&&tweet_data["user"]["name"]||nil
      tweet["retweet_count"] = tweet_data["retweet_count"]
      tweets << tweet
    end
    return tweets
  end

  def self.generate_edges(datasheet, start_date, end_date)
    edges = []
    datasheet.select{|potential_edge| !potential_edge["in_reply_to_status_id"].nil?}.each do |edge_data|
      if Time.parse(edge_data["created_at"]) <= end_date && Time.parse(edge_data["created_at"]) >= start_date
        edge = {}
        edge["start_node"] = edge_data["in_reply_to_screen_name"]
        edge["end_node"] = edge_data["user"]["screen_name"]
        edge["edge_id"] = edge_data["id"]
        edge["style"] = "behavioral_retweet"
        edges << edge
      end
    end
    return edges
  end
end
PullProfiles.collect_profile_data