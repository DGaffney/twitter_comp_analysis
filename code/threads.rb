require 'rubygems'
require 'dm-core'
require 'dm-aggregates'
require 'models/tweet'
require 'models/tweets_chosen_thread'
require 'models/user'
require 'extensions/date'
DataMapper.finalize
require 'utils'
require 'fastercsv'

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
  
  def self.durations(db="e")
    DataMapper.setup(:default, "mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/#{@all_my_bases[db]}")
    thread_durations = {}
    thread_ids = DataMapper.repository(:default).adapter.select("select distinct thread_id from tweets_chosen_threads").compact.reject {|i| i < 1 }
    puts "Found #{thread_ids.length} threads."
    for thread_id in thread_ids
      # size = DataMapper.repository(:default).adapter.select("select count(id) from tweets_chosen_threads where thread_id=#{thread_id}").first
      # if size > 1
        # print "#{thread_id} "
        print "."
        start_time = TweetsChosenThread.first(:thread_id => thread_id, :fields => [ :pubdate ], :order => [ :pubdate.asc ]).pubdate
        end_time = TweetsChosenThread.first(:thread_id => thread_id, :fields => [ :pubdate ], :order => [ :pubdate.desc ]).pubdate
        if !start_time.nil? && !end_time.nil?
          # puts start_time.gmt.inspect
          # puts end_time.gmt.inspect
          # puts end_time.gmt.to_i - start_time.gmt.to_i
          # gets
          thread_durations[thread_id] = {:duration => (end_time.gmt.to_i - start_time.gmt.to_i)}#, :size => size}
          # puts thread_durations[thread_id].inspect
        end
      # end
    end
    return thread_durations
  end
  
end