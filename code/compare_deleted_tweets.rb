require 'rubygems'
require 'dm-core'
# require 'dm-validations'
`ls models`.split("\n").each {|model| require "models/#{model}"}
require 'utils'
require 'extensions/array'
DataMapper.finalize


DataMapper.setup(:tunisia, "mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1")
DataMapper.setup(:test, "mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit")
DataMapper.setup(:egypt, "mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_2")

tunisia_result = {"200" => 0, "404" => 0}
test_result = {"200" => 0, "404" => 0}
egypt_result = {"200" => 0, "404" => 0}
limit=2000
DataMapper.repository(:test).adapter.select("select twitter_id from tweets where scrape_id = 1019 order by rand() limit #{limit}").each do |twitter_id|
  tweet_data,user_data = Utils.tweet_data(twitter_id) rescue nil
  if tweet_data&&user_data
    test_result["200"]+=1
  else
    test_result["404"]+=1
  end
end

DataMapper.repository(:tunisia).adapter.select("select twitter_id from tweets order by rand() limit #{limit}").each do |twitter_id|
  tweet_data,user_data = Utils.tweet_data(twitter_id) rescue nil
  if tweet_data&&user_data
    tunisia_result["200"]+=1
  else
    tunisia_result["404"]+=1
  end
end

DataMapper.repository(:egypt).adapter.select("select twitter_id from tweets order by rand() limit #{limit}").each do |twitter_id|
  tweet_data,user_data = Utils.tweet_data(twitter_id) rescue nil
  if tweet_data&&user_data
    egypt_result["200"]+=1
  else
    egypt_result["404"]+=1
  end
end

puts "Test 200/404 Ratio:#{test_result["200"]/test_result["404"].to_f}"
puts "Tunisia 200/404 Ratio:#{tunisia_result["200"]/tunisia_result["404"].to_f}"
puts "Egypt 200/404 Ratio:#{egypt_result["200"]/egypt_result["404"].to_f}"