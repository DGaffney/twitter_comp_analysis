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

all_my_bases = {"e" => "140kit_scratch_2", "t" => "140kit_scratch_1"}
rightful_names = {'e' => 'egypt', 't' => 'tunisia'}

class ProfileCategorization
  
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
    results = self.generate_core_stats(categories)
    puts results.inspect
    self.store_categorized_csvs(results)
  end
  
  def self.generate_core_stats(categories)
    references = self.preload_references
    categories.each_pair do |category, user_hashes|
      user_hashes.each do |user_hash|
        user_hash = self.generate_user_attributes(user_hash, references)
        user_hash = self.generate_native_behavior(user_hash, references)
        user_hash = UserBehavior.generate_user_behavior(user_hash, references)
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
  
  def self.generate_native_behavior(user_hash, references=nil)
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
  
  def self.store_categorized_csvs(results)
    results.each_pair do |category, user_hashes|
      `mkdir datasets/`
      `mkdir datasets/profile_categorization`
      keys = []
      first=true
      FasterCSV.open("datasets/profile_categorization/#{category}_users.csv", "w+") do |csv|
        user_hashes.each do |user_hash|
          if first
            keys = user_hashes.first.keys
            values = user_hashes.first.values
            csv << keys
            csv << values
            first=false
          end
          csv << keys.collect{|key| user_hash[key].to_s}
        end
      end
    end
  end
end

$db = all_my_bases[ARGV[0]]
$db_rightful_name = rightful_names[ARGV[0]]
ProfileCategorization.setup('gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', $db)
ProfileCategorization.pull_csv($db_rightful_name)