class ChosenThread
  include DataMapper::Resource
  property :id, Serial
  property :text, Text
  property :pubdate, DateTime
  property :link, String
  property :author, String
  property :realname, String
  property :storyquery, String
  property :thread_id, Serial
  property :words, Text
  property :shared_words, Text
  property :hashtags, Text
  property :mentions, Text
  property :datetime, DateTime
  property :twitter_id, Serial
end
