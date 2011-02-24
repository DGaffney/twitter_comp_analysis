class BehaviorTweet
  include DataMapper::Resource
  property :id,           Serial
  property :twitter_id,   Integer
  property :tweet_id,   Integer
  property :text,         Text
  property :language,     String
  property :source,     Text
  property :user_id,      Integer
  property :screen_name,  String
  property :username,  String
  property :location,     String
  property :in_reply_to_status_id, Integer
  property :in_reply_to_user_id,   Integer
  property :truncated,    String
  property :in_reply_to_screen_name, String
  property :created_at,   DateTime
  property :updated_at,   DateTime
  property :flagged,          Boolean
  property :dataset_id,   Integer
  property :lat,          String
  property :lon,          String
  property :dataset_id,   Integer
  property :pubdate,   DateTime
  property :link,   Text
  property :author,   String
  property :realname,   String
  property :storyquery,   String
  property :datetime,   String
  property :message, String
  property :analysis_finished, String
  property :tweet_collector_id, Integer
  property :user_name, String
  property :retweet_count,  Integer
  property :shared_words, Text
  belongs_to :user
end