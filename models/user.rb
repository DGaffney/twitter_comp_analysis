class User
  include DataMapper::Resource
  property :id, Serial
  property :twitter_id, Integer
  property :name, String
  property :screen_name, String
  property :location, Text
  property :description, Text
  property :profile_image_url, Text
  property :url, String
  property :protected, Boolean
  property :followers_count, Integer
  property :profile_background_color, String
  property :profile_text_color, String
  property :profile_link_color, String
  property :profile_sidebar_fill_color, String
  property :profile_sidebar_border_color, String
  property :friends_count, Integer
  property :created_at, DateTime
  property :favourites_count, Integer
  property :utc_offset, Integer
  property :time_zone, Text
  property :profile_background_image_url, Text
  property :profile_background_tile, Boolean
  property :notifications, Boolean
  property :geo_enabled, Boolean
  property :verified, Boolean
  property :following, Boolean
  property :statuses_count, Integer
  # property :contributers_enabled, Boolean
  property :lang, String
  property :listed_count, Integer
  property :dataset_id, Integer
  property :flagged, Boolean
  property :listed_count, Integer
  property :dataset_id, Integer
  property :username, String
  property :updated_at, DateTime
  property :total_tweets, Integer
  property :account_birth, DateTime
  property :friends, Integer
  property :followers, Integer
  property :more_tweet_checked, Boolean
  property :user_stats_checked, Boolean
  property :analysis_finished, Boolean
  has n, :tweets
end
