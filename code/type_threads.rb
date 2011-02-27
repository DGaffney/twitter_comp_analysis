require 'digest/sha1'
require 'extensions/array'
require 'extensions/string'
load "new_de_gilader.rb"
load "analysis.rb"
DataMapper.setup(:default, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')
DataMapper.setup(:tunisia, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
DataMapper.setup(:egypt, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2')

module TypeThreads
  def self.run
    thread_ids = DataMapper.repository(:default).adapter.select("select distinct(thread_id) from tweets_chosen_threads")
    thread_ids.each do |thread_id|
      tweets = TweetsChosenThread.all(:thread_id => thread_id).sort{|x,y| x.pubdate<=>y.pubdate}
      path = tweets.collect{||}
    end
  end
end

gg = DataMapper.repository(:default).adapter.select("select distinct(author) from tweets_chosen_threads")