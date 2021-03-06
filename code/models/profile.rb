class Profile
  include DataMapper::Resource
  property :p_id, Serial
  property :p_cc, Integer
  property :p_degree, Integer
  property :p_twitter_id, Integer
  property :p_screen_name, String
  property :p_realname, String
  property :p_type, Integer
  property :p_location, Text
  property :p_description, Text
  property :p_url, Text
  property :p_language, String
  property :p_website_type, String
  property :p_notes, Text
  property :p_followers, Text
  property :p_following, Text
  property :p_following_count, Integer
  property :p_follower_count, Integer
  property :p_in, Text
  property :p_out, Text
  property :p_statuses_count, Integer
  property :p_picture, Text
  property :p_created_at, DateTime
  property :p_time_zone, String
  property :p_utc_offset, String
  property :p_verified, String
  property :p_geo_enabled, Integer
  property :p_lang, String
  property :p_first_pubdate, DateTime
  property :p_first_text, Text
  property :p_participation, Integer
  property :p_protected, Integer
  property :last_update, DateTime
  property :times, Integer
  property :erhardt, Integer
  property :gilad, Integer
  property :danah, Integer
  property :mike, Integer
  property :p_edited_by, Text
end
