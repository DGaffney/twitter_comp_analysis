class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :twitter_id
      t.string :name
      t.string :screen_name
      t.text :location
      t.text :description
      t.text :profile_image_url
      t.text :url
      t.boolean :protected
      t.integer :followers_count
      t.string :profile_background_color
      t.string :profile_text_color
      t.string :profile_link_color
      t.string :profile_sidebar_fill_color
      t.string :profile_sidebar_border_color
      t.integer :friends_count
      t.datetime :created_at
      t.integer :favourites_count
      t.integer :utc_offset
      t.text :time_zone
      t.text :profile_background_image_url
      t.boolean :profile_background_tile
      t.boolean :notifications
      t.boolean :geo_enabled
      t.boolean :verified
      t.boolean :following
      t.integer :statuses_count
      t.string :lang
      t.integer :listed_count
      t.integer :dataset_id
      t.boolean :flagged
      t.integer :listed_count
      t.integer :dataset_id
      t.string :username
      t.datetime :updated_at
      t.integer :total_tweets
      t.datetime :account_birth
      t.integer :friends
      t.integer :followers
      t.boolean :more_tweet_checked
      t.boolean :user_stats_checked
      t.boolean :analysis_finished

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
