require 'digest/sha1'
require 'extensions/array'
require 'extensions/string'
load "new_de_gilader.rb"
NewDeGilader.setup('gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', '140kit_scratch_1')
DataMapper.finalize
DataMapper.setup(:default, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')
DataMapper.setup(:tunisia, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
DataMapper.setup(:egypt, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')
limit = 1000
offset = 0

module GeocodeTweets
  def self.insert(model, records, database=:default)
    keys = nil
    sql_query = "replace into #{model} (#{(keys=records.first.keys.collect{|x| x.to_s}).join(", ")}) VALUES "
    records.each do |record|
      row = keys.collect{|key| "?,"}
      sql_query+="(#{row.to_s.chop}), "
    end
    sql_query = sql_query.chop.chop
    gg = records.collect{|record| keys.collect{|key| record[key.to_sym]}}.flatten
    DataMapper.repository(database).adapter.execute(sql_query, *gg)
  end

  def self.bulk_worker(model, conditions, query="", limit=1000, threads=10)
    offset = 0
    last_id = DataMapper.repository(:default).adapter.select("select id from #{model} #{query} order by id desc limit 1").first
    thread_list = []
    while last_id>offset+limit
      conditions[:limit] = limit
      conditions[:offset] = offset
      conditions[:order] = :id.desc
      grouped_objects = model.classify.constantize.all(conditions).chunk(threads)
      grouped_objects.each do |objects|
        thread_list<<Thread.new do
          orig_objects = Digest::SHA1.hexdigest(objects.collect{|o| o.attributes}.to_s)
          puts orig_objects
          puts objects.collect{|x| [x.lat, x.lon]}.inspect
          objects = yield objects
          debugger
          puts objects.collect{|x| [x.lat, x.lon]}.inspect
          new_objects = Digest::SHA1.hexdigest(objects.collect{|o| o.attributes}.to_s)
          puts new_objects
          if new_objects!=orig_objects
            if objects.first.class!=Hash
              objects = objects.collect{|obj| obj.attributes}
            end
            insert(model, objects) 
          end
        end
        thread_list.collect{|t| t.join}
      end
      if offset+limit>last_id
        limit = last_id-offset
      else
        offset+=limit
      end
    end
  end
  
  def self.geocode_tweets
    GeocodeTweets.bulk_worker("tweets", {:lat => nil, :lon => nil}, "where lat is null and lon is null")  do |tweets|
      tweets.each do |tweet|
        puts tweet.twitter_id
        tweet_data = Utils.tweet_data(tweet.twitter_id)
        if tweet.lat.nil?
          tweet.lat = tweet_data.first["coordinates"] &&
          tweet_data.first["coordinates"]["coordinates"] && 
          tweet_data.first["coordinates"]["coordinates"].last ||
          tweet_data.first["geo"] &&
          tweet_data.first["geo"]["coordinates"] &&
          tweet_data.first["geo"]["coordinates"].last ||
          tweet_data.first["place"] && 
          tweet_data.first["place"]["bounding_box"] && 
          tweet_data.first["place"]["bounding_box"]["coordinates"] && 
          tweet_data.first["place"]["bounding_box"]["coordinates"].first &&
          tweet_data.first["place"]["bounding_box"]["coordinates"].first.first &&
          tweet_data.first["place"]["bounding_box"]["coordinates"].first.first.last ||
          tweet_data.last["location"] &&
          !tweet_data.last["location"].scan("ÜT: ").empty? &&
          tweet_data.last["location"].gsub("ÜT: ").split(",").first ||
          "0"
        end
        if tweet.lon.nil?
          tweet.lon = tweet_data.first["coordinates"] &&
          tweet_data.first["coordinates"]["coordinates"] && 
          tweet_data.first["coordinates"]["coordinates"].first ||
          tweet_data.first["geo"] &&
          tweet_data.first["geo"]["coordinates"] &&
          tweet_data.first["geo"]["coordinates"].first ||
          tweet_data.first["place"] && 
          tweet_data.first["place"]["bounding_box"] && 
          tweet_data.first["place"]["bounding_box"]["coordinates"] && 
          tweet_data.first["place"]["bounding_box"]["coordinates"].first &&
          tweet_data.first["place"]["bounding_box"]["coordinates"].first.first &&
          tweet_data.first["place"]["bounding_box"]["coordinates"].first.first.first ||
          tweet_data.last["location"] &&
          !tweet_data.last["location"].scan("ÜT: ").empty? &&
          tweet_data.last["location"].gsub("ÜT: ").split(",").last ||
          "0"
        end
      end
      tweets
    end
  end

end
GeocodeTweets.geocode_tweets
