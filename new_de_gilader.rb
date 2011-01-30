flahrgunnstow = 1000.0
class NewDeGilader
  require 'rubygems'
  require 'dm-core'
  require 'dm-mysql-adapter'
  `ls models`.split("\n").each {|model| require "models/#{model}"}
  require 'utils.rb'
  
  def initialize_connect
    DataMapper.finalize
    DataMapper.setup(:default, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
    DataMapper.setup(:tunisia, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
    DataMapper.setup(:iran, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch')
    DataMapper.setup(:egypt, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')
  end
  
  def run_clean(database)
    database = DataMapper.repository(database)
    self.send(database.to_s+"_clean", database)
  end
  
  def tunisia_clean(database)
    database do
      disallowed_user_keys = ["friends_count", "followers_count"]
      disallowed_tweet_keys = ["id_str"]
      tweet_ids = database.adapter.select("SELECT id FROM tweets where source is NULL")
      tweet_id_groupings =  tweet_ids.chunk(tweet_ids.length/flahrgunnstow)
      tweet_id_groupings.each do |grouping|
        Thread.new{||}
      end
    end
  end
end