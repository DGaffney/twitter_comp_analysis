require 'rubygems'
require 'dm-core'
require 'dm-validations'
current_path = File.dirname(__FILE__) + "/"

require "user_behavior.rb"
require "#{current_path}utils.rb"
require "#{current_path}analysis.rb"
require 'fastercsv'


`ls models`.split("\n").each {|model| require "#{current_path}/models/#{model}"}
`ls analyses`.split("\n").each {|analysis| require "#{current_path}analyses/#{analysis}"}
`ls extensions`.split("\n").each {|analysis| require "#{current_path}extensions/#{analysis}"}

DataMapper.finalize

class ThreadPumper
  def self.pump_them_threads(shorty, limit=302)
    all_my_bases = {"e" => "140kit_scratch_2", "t" => "140kit_scratch_1"}
    rightful_names = {'e' => 'egypt', 't' => 'tunisia'}
    $db = all_my_bases[shorty]
    $db_rightful_name = rightful_names[shorty]
    $categories = self.pull_csv($db_rightful_name)
    ThreadPumper.setup('gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', $db)
    threads = DataMapper.repository(:default).adapter.select("select thread_id,count(id) as count from tweets group by thread_id order by count(id) desc limit #{limit}")
    threads.each do |thread|
      if thread.thread_id!=0 && !thread.thread_id.nil?
        results = self.get_thread_results(thread.thread_id)
        self.store_categorized_csvs(results, "thread_count_#{thread.count}_id_#{thread.thread_id}")
      end
    end
  end
  
  def self.get_thread_results(thread)
    puts "Working on thread #{thread}"
    result = []
    puts "Pulling tweets for #{thread}"
    tweets = Tweet.all(:thread_id => thread, :order => [:created_at.asc])
    puts "Pulled #{tweets.length} tweets for #{thread}"
    tweets.each do |tweet|
      thread_row = {}
      thread_row[:originator] = tweet == tweets.first ? true : false
      thread_row[:text] = tweet.text
      thread_row[:screen_name] = tweet.screen_name
      thread_row[:replied_to] = tweet.in_reply_to_screen_name || 'n/a'
      thread_row[:user_type] = self.find_user_type(tweet.screen_name)
      thread_row[:created_at] = tweet.pubdate.strftime("%Y-%m-%d %H:%M:%S")
      result << thread_row
    end
    puts "#{result.length} tweets in this thread"
    return result
  end
  
  def self.find_user_type(screen_name)
    cat = "normal_user"
    categories = self.pull_csv($db_rightful_name)
    categories.each_pair do |category, users|
      cat = category if users.collect{|user| user.values}.flatten.include?(screen_name)
    end
    return cat
  end
  
  def self.setup(username, password, hostname, database)
    DataMapper.setup(:default, "mysql://#{username}:#{password}@#{hostname}/#{database}")
  end
  
  def self.pull_csv(name)
    f = File.open("datasets/profile_categorization/source/#{name}.csv")
    categories = {}
    dataset = f.read.split(/[\n|\r\n]/).collect{|x| x.split(",")}
    dataset.each do |d|
      case d.last
      when "1"
        categories["msm"] = [] if categories["msm"].nil?
        categories["msm"] << {:screen_name => d.first} if !categories["msm"].include?({:screen_name => d.first})
      when "2"
        categories["journalist"] = [] if categories["journalist"].nil?
        categories["journalist"] << {:screen_name => d.first} if !categories["journalist"].include?({:screen_name => d.first})        
      when "3"
        categories["blogger"] = [] if categories["blogger"].nil?
        categories["blogger"] << {:screen_name => d.first} if !categories["blogger"].include?({:screen_name => d.first})
      when "4"
        categories["celeb"] = [] if categories["celeb"].nil?
        categories["celeb"] << {:screen_name => d.first} if !categories["celeb"].include?({:screen_name => d.first})
      when "5"
        categories["etc"] = [] if categories["etc"].nil?
        categories["etc"] << {:screen_name => d.first} if !categories["etc"].include?({:screen_name => d.first})
      end
    end
    return categories
  end
  
  def self.store_categorized_csvs(results, name, date=nil)
    `mkdir datasets/`
    `mkdir datasets/threads`
    keys = ["screen_name", "user_type", "text", "created_at", "originator", "replied_to"]
    first=true
    date_stamp = date.nil? ? "_total" : date.strftime("_%m-%d")
    FasterCSV.open("datasets/threads/#{name}.csv", "w+") do |csv|
      csv << keys
      results.each do |result|
        csv << keys.collect{|key| result[key.to_sym].to_s}
      end
    end
  end
end

ThreadPumper.pump_them_threads("e")