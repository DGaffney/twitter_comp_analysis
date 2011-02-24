class TweetsChosenThread
  include DataMapper::Resource
  property :id, Serial
  property :text, Text, :lazy => false
  property :pubdate, DateTime
  property :link, String
  property :author, String
  property :realname, String
  property :storyquery, String
  property :thread_id, Integer
  property :words, Text, :lazy => false
  property :shared_words, Text, :lazy => false
  property :hashtags, Text, :lazy => false
  property :mentions, Text, :lazy => false
  property :datetime, DateTime
  property :twitter_id, Integer
end
