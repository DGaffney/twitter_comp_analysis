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

class ProfileCategorization
  
  def self.run(shorty)
    all_my_bases = {"e" => "140kit_scratch_2", "t" => "140kit_scratch_1"}
    rightful_names = {'e' => 'egypt', 't' => 'tunisia'}
    $db = all_my_bases[shorty]
    $db_rightful_name = rightful_names[shorty]
    ProfileCategorization.setup('gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', $db)
    start_date, end_date = $db_rightful_name=="egypt" ? [Time.parse("2011-1-18 00:00:00"), Time.parse("2011-1-30 00:00:00")] : [Time.parse("2011-1-08 00:00:00"), Time.parse("2011-1-20 00:00:00")]
    start_date.day.upto(end_date.day) do |day|
      categories = ProfileCategorization.pull_csv($db_rightful_name)
      results = ProfileCategorization.generate_core_stats(categories, Time.parse("2011-1-#{day} 00:00:00"))
      puts results.inspect
      ProfileCategorization.store_categorized_csvs(results, $db_rightful_name, Time.parse("2011-1-#{day} 00:00:00"))
    end
    categories = ProfileCategorization.pull_csv($db_rightful_name)
    results = ProfileCategorization.generate_core_stats(categories)
    puts results.inspect
    ProfileCategorization.store_categorized_csvs(results, $db_rightful_name)
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
  
  def self.generate_core_stats(categories, date=nil)
    references = self.preload_references
    categories.each_pair do |category, user_hashes|
      user_hashes.each do |user_hash|
        user_hash = self.generate_user_attributes(user_hash, references)
        user_hash = self.generate_native_behavior(user_hash, references, date)
      end
    end
    return categories
  end
  
  def self.preload_references
    followers_percentile_array = DataMapper.repository(:default).adapter.select("select screen_name,followers_count from users order by followers_count desc")
    friends_percentile_array = DataMapper.repository(:default).adapter.select("select screen_name,friends_count from users order by followers_count desc")
    statuses_percentile_array = DataMapper.repository(:default).adapter.select("select screen_name,statuses_count from users order by followers_count desc")
    return {:followers_percentile_array => followers_percentile_array, :friends_percentile_array => friends_percentile_array, :statuses_percentile_array => statuses_percentile_array}
  end
  
  def self.generate_user_attributes(user_hash, references=nil)
    user = User.first(:screen_name => user_hash[:screen_name])
    user_hash[:followers_count] = user.followers_count rescue 'n/a'
    user_hash[:followers_percentile] = self.generate_percentile(references[:followers_percentile_array], "screen_name", user.screen_name) rescue 'n/a'
    user_hash[:friends_count] = user.friends_count rescue 'n/a'
    user_hash[:friends_percentile] = self.generate_percentile(references[:friends_percentile_array], "screen_name", user.screen_name) rescue 'n/a'
    user_hash[:statuses_count] = user.statuses_count rescue 'n/a'
    user_hash[:statuses_percentile] = self.generate_percentile(references[:statuses_percentile_array], "screen_name", user.screen_name) rescue 'n/a'
    user_hash[:created_at] = user.created_at.strftime("%Y-%m-%d %H:%M:%S") rescue 'n/a'
    if user
      puts "Generated User #{user.screen_name}..."
    else
      puts "Failed Lookup on #{user_hash[:screen_name]}..."
    end
    return user_hash
  end
  
  def self.generate_native_behavior(user_hash, references=nil, date=nil)
    egypt_keys = %w{ egypt mubarak jan25 tahrir }
    tunisia_keys = %w{ sidibouzid tunisia jasmine }
    keywords = $db_rightful_name=="egypt" ? egypt_keys : tunisia_keys
    start_date,end_date = date.nil? ? [nil,nil] : [date.strftime("%Y-%m-%d 00:00:00"), date.strftime("%Y-%m-%d 23:59:59")]
    behavior_tweets = []
    if start_date&&end_date
      behavior_tweets = DataMapper.repository(:default).adapter.select("select * from behavior_tweets where screen_name = ? and created_at >= ? and created_at <= ?", user_hash[:screen_name], start_date, end_date)
    else
      behavior_tweets = DataMapper.repository(:default).adapter.select("select * from behavior_tweets where screen_name = ?", user_hash[:screen_name])
    end
    behavior_tweets.each do |tweet|
      context = tweet.text.scan(/(#{keywords.join('|')})/).empty? ? "irrelevant" : "relevant"
      user_hash["#{context}_user_gets_retweeted".to_sym] = 0 if user_hash["#{context}_user_gets_retweeted".to_sym].nil?
      user_hash["#{context}_user_gets_retweeted".to_sym]+=1 if tweet.retweet_count>0
      user_hash["#{context}_user_retweets".to_sym] = 0 if user_hash["#{context}_user_retweets".to_sym].nil?
      user_hash["#{context}_user_retweets".to_sym] if !tweet.in_reply_to_status_id.nil?
      user_hash["#{context}_total".to_sym] = 0 if user_hash["#{context}_total".to_sym].nil?
      user_hash["#{context}_total".to_sym]+=1
    end
    ["irrelevant", "relevant"].each do |context|
      user_hash["#{context}_percent_user_retweets".to_sym] = user_hash["#{context}_user_retweets".to_sym] && user_hash["#{context}_total".to_sym] && user_hash["#{context}_user_retweets".to_sym]/user_hash["#{context}_total".to_sym].to_f || 'n/a'
      user_hash["#{context}_percent_user_gets_retweeted".to_sym] = user_hash["#{context}_user_gets_retweeted".to_sym] && user_hash["#{context}_total".to_sym] && user_hash["#{context}_user_gets_retweeted".to_sym]/user_hash["#{context}_total".to_sym].to_f || 'n/a' 
      user_hash["#{context}_percent_original_tweets".to_sym] = user_hash["#{context}_user_retweets".to_sym] && user_hash["#{context}_total".to_sym] && 1-user_hash["#{context}_user_retweets".to_sym]/user_hash["#{context}_total".to_sym].to_f || 'n/a'
      user_hash["#{context}_total".to_sym] = user_hash["#{context}_total".to_sym] || 'n/a'
    end
    return user_hash
  end
  
  def self.generate_percentile(dataset, key, value)
    placement = 0
    total = dataset.length
    dataset.each do |datum|
      break if datum.send(key) == value
      placement+=1
    end
    return 1-placement/total.to_f
  end
  
  def self.store_categorized_csvs(results, name, date=nil)
    results.each_pair do |category, user_hashes|
      `mkdir datasets/`
      `mkdir datasets/profile_categorization`
      keys = ["screen_name", "relevant_total", "irrelevant_total", "friends_count", "friends_percentile", "followers_count", "followers_percentile", "statuses_count", "statuses_percentile", "created_at", "relevant_user_gets_retweeted", "relevant_user_retweets", "relevant_percent_user_gets_retweeted", "relevant_percent_user_retweets", "irrelevant_user_gets_retweeted", "irrelevant_user_retweets", "irrelevant_percent_user_gets_retweeted", "irrelevant_percent_user_retweets"]
      first=true
      date_stamp = date.nil? ? "_total" : date.strftime("_%m-%d")
      FasterCSV.open("datasets/profile_categorization/#{name}_#{category}_users#{date_stamp}.csv", "w+") do |csv|
        csv << keys
        user_hashes.each do |user_hash|
          csv << keys.collect{|key| user_hash[key.to_sym].to_s}
        end
      end
    end
  end
end

ProfileCategorization.run("e")
