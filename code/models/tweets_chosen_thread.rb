class TweetsChosenThread
  include DataMapper::Resource
  property :id, Serial
  property :text, Text
  property :pubdate, DateTime
  property :link, String
  property :author, String
  property :realname, String
  property :storyquery, String
  property :thread_id, Integer
  property :words, Text
  property :shared_words, Text
  property :hashtags, Text
  property :mentions, Text
  property :datetime, DateTime
  property :twitter_id, Integer
end
