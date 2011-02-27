# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110223031037) do

  create_table "behavior_tweets", :id => false, :force => true do |t|
    t.integer  "id"
    t.integer  "twitter_id",              :limit => 8,    :default => 0
    t.string   "username"
    t.datetime "published"
    t.integer  "tweet_id"
    t.string   "text",                    :limit => 1000
    t.text     "source"
    t.string   "language"
    t.integer  "user_id",                 :limit => 8,    :default => 0
    t.string   "screen_name"
    t.string   "location"
    t.integer  "in_reply_to_status_id",   :limit => 8,    :default => 0
    t.integer  "in_reply_to_user_id",     :limit => 8,    :default => 0
    t.string   "truncated"
    t.string   "in_reply_to_screen_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lat"
    t.string   "lon"
    t.boolean  "flagged",                                 :default => false
    t.integer  "dataset_id"
    t.integer  "retweet_count"
    t.datetime "pubdate"
    t.string   "link",                    :limit => 400
    t.string   "author",                  :limit => 400
    t.string   "realname",                :limit => 400
    t.string   "storyquery",              :limit => 400
    t.datetime "datetime"
    t.string   "message"
    t.boolean  "analysis_finished"
    t.integer  "tweet_collector_id"
    t.string   "user_name"
  end

  add_index "behavior_tweets", ["screen_name"], :name => "screen_name"
  add_index "behavior_tweets", ["twitter_id"], :name => "index_tweets_on_twitter_id_and_dataset_id", :unique => true

  create_table "chosen_threads", :force => true do |t|
    t.integer  "count",                         :null => false
    t.string   "screen_name",  :limit => 200,   :null => false
    t.integer  "source_type",                   :null => false
    t.string   "first_text",   :limit => 20000, :null => false
    t.string   "identified",   :limit => 100,   :null => false
    t.string   "mentioned",    :limit => 2000,  :null => false
    t.datetime "start",                         :null => false
    t.datetime "end",                           :null => false
    t.string   "notes",        :limit => 20000, :null => false
    t.integer  "duration",                      :null => false
    t.string   "duration_str", :limit => 100,   :null => false
  end

  create_table "edges", :force => true do |t|
    t.integer  "graph_id",                   :default => 0
    t.string   "start_node"
    t.string   "end_node"
    t.integer  "edge_id",       :limit => 8, :default => 0
    t.datetime "time"
    t.integer  "collection_id",              :default => 0
    t.boolean  "flagged",                    :default => false
    t.string   "lock"
    t.string   "style"
  end

  add_index "edges", ["collection_id"], :name => "edge_collection_id"
  add_index "edges", ["end_node"], :name => "end_node"
  add_index "edges", ["graph_id", "collection_id"], :name => "edge_graph_id_collection_id"
  add_index "edges", ["graph_id"], :name => "edge_graph_id"
  add_index "edges", ["start_node", "end_node", "edge_id", "style", "graph_id"], :name => "unique_edge", :unique => true
  add_index "edges", ["start_node"], :name => "start_node"
  add_index "edges", ["time"], :name => "edges_time"

  create_table "graph_points", :force => true do |t|
    t.datetime "created_at", :null => false
    t.string   "key",        :null => false
    t.string   "value",      :null => false
    t.integer  "graph_id",   :null => false
  end

  add_index "graph_points", ["key"], :name => "graph_point_key"
  add_index "graph_points", ["value"], :name => "value"

  create_table "graphs", :force => true do |t|
    t.string   "title"
    t.string   "style"
    t.integer  "collection_id", :default => 0
    t.integer  "month"
    t.integer  "year"
    t.boolean  "written",       :default => false
    t.string   "lock"
    t.boolean  "flagged",       :default => false
    t.datetime "time_slice"
    t.integer  "hour"
    t.integer  "date"
    t.integer  "curation_id"
  end

  add_index "graphs", ["hour"], :name => "hour"
  add_index "graphs", ["month", "year", "hour"], :name => "day_2"
  add_index "graphs", ["month", "year"], :name => "month_3"
  add_index "graphs", ["month"], :name => "month"
  add_index "graphs", ["title", "style", "collection_id", "time_slice", "year", "month", "date", "hour"], :name => "unique_graph", :unique => true
  add_index "graphs", ["year"], :name => "year"

  create_table "profiles", :id => false, :force => true do |t|
    t.integer  "p_id",                                    :default => 0,  :null => false
    t.float    "p_cc"
    t.integer  "p_degree",                                :default => 0,  :null => false
    t.integer  "p_twitter_id",                            :default => 0,  :null => false
    t.string   "p_screen_name",     :limit => 100,        :default => "", :null => false
    t.string   "p_realname",        :limit => 100,        :default => "", :null => false
    t.integer  "p_type",                                  :default => 0,  :null => false
    t.string   "p_location",        :limit => 400,        :default => "", :null => false
    t.text     "p_description",     :limit => 2147483647,                 :null => false
    t.string   "p_url",             :limit => 400,        :default => "", :null => false
    t.string   "p_language",        :limit => 400,        :default => "", :null => false
    t.string   "p_website_type",    :limit => 400,        :default => "", :null => false
    t.text     "p_notes",           :limit => 2147483647,                 :null => false
    t.text     "p_followers",       :limit => 2147483647,                 :null => false
    t.text     "p_following",       :limit => 2147483647,                 :null => false
    t.integer  "p_following_count",                       :default => 0,  :null => false
    t.integer  "p_follower_count",                        :default => 0,  :null => false
    t.text     "p_in",              :limit => 2147483647,                 :null => false
    t.text     "p_out",             :limit => 2147483647,                 :null => false
    t.integer  "p_statuses_count",                        :default => 0,  :null => false
    t.string   "p_picture",         :limit => 200,        :default => "", :null => false
    t.datetime "p_created_at",                                            :null => false
    t.string   "p_time_zone",       :limit => 400,        :default => "", :null => false
    t.string   "p_utc_offset",      :limit => 100,        :default => "", :null => false
    t.string   "p_verified",        :limit => 100,        :default => "", :null => false
    t.integer  "p_geo_enabled",                           :default => 0,  :null => false
    t.string   "p_lang",            :limit => 20,         :default => "", :null => false
    t.datetime "p_first_pubdate",                                         :null => false
    t.text     "p_first_text",      :limit => 2147483647,                 :null => false
    t.integer  "p_participation",                         :default => 0,  :null => false
    t.integer  "p_protected",                             :default => 0,  :null => false
    t.datetime "last_update",                                             :null => false
    t.integer  "times",                                   :default => 0,  :null => false
    t.integer  "erhardt",           :limit => 1,          :default => 0,  :null => false
    t.integer  "gilad",             :limit => 1,          :default => 0,  :null => false
    t.integer  "danah",             :limit => 1,          :default => 0,  :null => false
    t.integer  "mike",              :limit => 1,          :default => 0,  :null => false
    t.string   "p_edited_by",       :limit => 200,                        :null => false
  end

  create_table "tweets", :force => true do |t|
    t.integer  "twitter_id",              :limit => 8,    :default => 0,     :null => false
    t.string   "username"
    t.datetime "published"
    t.integer  "tweet_id"
    t.string   "text",                    :limit => 1000
    t.string   "source",                  :limit => 500
    t.string   "language"
    t.integer  "user_id",                 :limit => 8,    :default => 0
    t.string   "screen_name"
    t.string   "location"
    t.integer  "in_reply_to_status_id",   :limit => 8,    :default => 0
    t.integer  "in_reply_to_user_id",     :limit => 8,    :default => 0
    t.string   "truncated"
    t.string   "in_reply_to_screen_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "lat"
    t.string   "lon"
    t.boolean  "flagged",                                 :default => false
    t.integer  "dataset_id"
    t.integer  "retweet_count"
    t.datetime "pubdate"
    t.string   "link",                    :limit => 500
    t.string   "author",                  :limit => 400
    t.string   "realname",                :limit => 400
    t.string   "storyquery",              :limit => 400
    t.datetime "datetime"
    t.string   "message"
    t.boolean  "analysis_finished"
    t.integer  "tweet_collector_id"
    t.string   "user_name"
    t.integer  "thread_id"
    t.string   "shared_words",            :limit => 400
    t.string   "words",                   :limit => 1000
  end

  add_index "tweets", ["screen_name"], :name => "screen_name"
  add_index "tweets", ["text"], :name => "text", :length => {"text"=>"255"}
  add_index "tweets", ["thread_id"], :name => "thread_id"
  add_index "tweets", ["twitter_id", "dataset_id"], :name => "index_tweets_on_twitter_id_and_dataset_id", :unique => true
  add_index "tweets", ["twitter_id"], :name => "twitter_id", :unique => true

