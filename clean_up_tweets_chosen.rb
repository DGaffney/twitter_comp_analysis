load "new_de_gilader.rb"
NewDeGilader.setup('gonkclub', 'cakebread', 'deebee.yourdefaulthomepage.com', '140kit_scratch_2')
def insert(model, records)
  keys = nil
  sql_query = "replace into #{model} (#{(keys=records.first.keys.collect{|x| x.to_s}).join(", ")}) VALUES "
  records.each do |record|
    row = keys.collect{|key| "?,"}
    sql_query+="(#{row.to_s.chop}), "
  end
  sql_query = sql_query.chop.chop
  gg = records.collect{|record| keys.collect{|key| record[key.to_sym]}}.flatten
  DataMapper.repository(:default).adapter.execute(sql_query, *gg)
end
limit = 1000
offset = 1000
last_id = DataMapper.repository(:default).adapter.select("select id from tweets_chosen_threads order by id desc limit 1").first
while last_id>offset+limit
tweets = Tweet.all(:words => nil, :limit => limit, :offset => offset)
scrubbed = []
tweets.each do |tweet|
  tweet = tweet.attributes
  tweet[:twitter_id] = 
  tweet[:words]=tweet[:text].split(" ").collect{|word| word.include?("http://") ? word : word.downcase.gsub(/[\[|\{|\]|\}|\;|\:|\'|\"|\(|\)|\*|\&|\^|\%|\$|\!|\<|\,|\>|\.|\?|\/]/, "")}.join(",")
  puts "#{tweet[:id]};#{tweet[:words]}"
  scrubbed << tweet
end
insert("tweets", scrubbed)
scrubbed = []
if offset+1000>last_id
limit = last_id-offset
else
offset+=1000
end
end