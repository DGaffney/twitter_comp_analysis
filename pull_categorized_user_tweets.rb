require 'utils'
require 'lib_files.rb'
require 'profile_categorization.rb'
module PullCategorizedUserTweets  
  MAX_COUNT_PER_BATCH_INSERT = 1000
  def self.pull_user_listing(name)
    user_hashes = ProfileCategorization.pull_csv(name)
  end
  
  def self.pull_tweets(user_hashes, name)
    start_date, end_date = name=="egypt" ? [Time.parse("2011-1-18 00:00:00"), Time.parse("2011-1-30 00:00:00")] : [Time.parse("2011-1-08 00:00:00"), Time.parse("2011-1-20 00:00:00")]
    username,password,hostname,database = 'gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', $db
    DataMapper.setup(:default, "mysql://#{username}:#{password}@#{hostname}/#{database}")
    tweet_records = []
    edge_records = []
    user_hashes.each_pair do |category, users_hash|
      puts "Evaluating #{category} users..."
      users_hash.each do |user_hash|
        puts "\tHashing #{user_hash[:screen_name]}..."
        last_date = Time.now
        page = 1
        previous_datasheet = []
        datasheet = Utils.statuses(user_hash[:screen_name], 100, true, page)
        while last_date > start_date && datasheet!=previous_datasheet && !datasheet.empty?
          puts "\t\tPage #{page}..."
          tweet_hashes, last_date = self.generate_hashes(datasheet, start_date, end_date)
          edge_hashes = self.generate_edges(datasheet, start_date, end_date)
          puts "\t\t\t#{tweet_hashes.length} Tweets, #{edge_hashes.length} Edges..."
          previous_datasheet=datasheet
          page+=1
          datasheet = Utils.statuses(user_hash[:screen_name], 100, true, page)
          tweet_records = tweet_records+tweet_hashes
          edge_records = edge_records+edge_hashes
          puts "\t\t\t#{tweet_records.length} Tweets total, #{edge_records.length} Edges total..."
        end
        puts "\tHashed #{user_hash[:screen_name]}. #{tweet_records.length} tweets, #{edge_records.length} edges."
        if tweet_records.length >= MAX_COUNT_PER_BATCH_INSERT
          puts "Reached #{tweet_records.length} tweets, saving now..."
          self.insert("behavior_tweets", self.uniq_tweets(tweet_records))
        end
        if edge_records.length > MAX_COUNT_PER_BATCH_INSERT
          puts "Reached #{edge_records.length} edges, saving now..."
          self.insert("edges", self.uniq_edges(edge_records))
        end
      end
    end
  end
  
  def self.uniq_tweets(tweets)
    puts "Uniquing returned data..."
    uniqued = []
    uniqued_ids = []
    tweets.each do |tweet|
      if !uniqued_ids.include?(tweet["twitter_id"])
        uniqued_ids << tweet["twitter_id"] 
        uniqued << tweet
      end
    end
    puts "Uniqued data crunched from #{tweets.length} => #{uniqued.length}..."
    return uniqued
  end
  
  def self.uniq_edges(edges)
    puts "Uniquing returned data..."
    uniqued = []
    uniqued_ids = []
    edges.each do |edge|
      if !uniqued_ids.include?(edge["edge_id"])
        uniqued_ids << edge["edge_id"] 
        uniqued << edge
      end
    end
    puts "Uniqued data crunched from #{edges.length} => #{uniqued.length}..."
    return uniqued
  end
  
  def self.generate_hashes(datasheet, start_date, end_date)
    last_date = Time.parse(datasheet.last["created_at"])
    tweets = []
    datasheet.each do |tweet_data|
      if Time.parse(tweet_data["created_at"]) <= end_date && Time.parse(tweet_data["created_at"]) >= start_date
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
    end
    return tweets, last_date
  end
  
  def self.generate_edges(datasheet, start_date, end_date)
    edges = []
    datasheet.select{|potential_edge| !potential_edge["in_reply_to_status_id"].nil?}.each do |edge_data|
      if Time.parse(edge_data["created_at"]) <= end_date && Time.parse(edge_data["created_at"]) >= start_date
        edge = {}
        edge["start_node"] = edge_data["in_reply_to_screen_name"]
        edge["end_node"] = edge_data["user"]["screen_name"]
        edge["edge_id"] = edge_data["in_reply_to_status_id"]
        edge["style"] = "behavioral_retweet"
        edges << edge
      end
    end
    return edges
  end

  #someone should write an e-mail and calmly explain to the datamapper guys why this bulk insert process is fucking stupid.
  def self.insert(model, records)
    sql_query = "insert ignore into #{model} (#{(keys=records.first.keys).join(", ")}) VALUES "
    records.each do |record|
      row = keys.collect{|key| "?,"}
      sql_query+="(#{row.to_s.chop}), "
    end
    sql_query = sql_query.chop.chop
    gg = records.collect{|record| keys.collect{|key| record[key]}}.flatten
    DataMapper.repository(:default).adapter.execute(sql_query, *gg)
  end
end
DataMapper.finalize

all_my_bases = {"e" => "140kit_scratch_2", "t" => "140kit_scratch_1"}
rightful_names = {'e' => 'egypt', 't' => 'tunisia'}

$db = all_my_bases[ARGV[0]]
$db_rightful_name = rightful_names[ARGV[0]]
user_hashes = PullCategorizedUserTweets.pull_user_listing("egypt")
PullCategorizedUserTweets.pull_tweets(user_hashes, "egypt")