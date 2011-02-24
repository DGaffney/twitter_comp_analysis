require 'rubygems'
require 'dm-core'
require 'dm-aggregates'
require 'models/tweet'
DataMapper.finalize
require 'utils'

module Threads
  
  @all_my_bases = {"e" => "140kit_scratch_2", "t" => "140kit_scratch_1"}
  
  def self.origins(db="e")
    DataMapper.setup(:default, "mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/#{@all_my_bases[db]}")
    thread_origins = {}
    thread_ids = DataMapper.repository(:default).adapter.select("select distinct thread_id from tweets").sort
    thread_ids.delete(0)
    for thread_id in thread_ids
      size = DataMapper.repository(:default).adapter.select("select count(id) from tweets where thread_id=#{thread_id}").first
      if size > 1
        tweet = Tweet.first(:thread_id => thread_id, :fields => [ :twitter_id, :screen_name, :text ], :order => [ :pubdate.asc ])
        thread_origins[thread_id] = { :status_id => tweet.twitter_id, :screen_name => tweet.screen_name, :text => tweet.text, :size => size }
        print "#{thread_id} "
        puts thread_origins[thread_id].inspect
      end
    end
    return thread_origins
  end
end