class CreateTweets < ActiveRecord::Migration
  def self.up
    create_table :tweets do |t|
      t.integer :twitter_id
      t.integer :tweet_id
      t.text :text
      t.string :language
      t.text :source
      t.integer :user_id
      t.string :screen_name
      t.string :username
      t.string :location
      t.integer :in_reply_to_status_id
      t.integer :in_reply_to_user_id
      t.string :truncated
      t.string :in_reply_to_screen_name
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :published
      t.boolean :flagged
      t.integer :dataset_id
      t.string :lat
      t.string :lon
      t.integer :dataset_id
      t.datetime :pubdate
      t.text :link
      t.string :author
      t.string :realname
      t.string :storyquery
      t.string :datetime
      t.string :message
      t.string :analysis_finished
      t.integer :tweet_collector_id
      t.string :user_name
      t.integer :retweet_count
      t.integer :thread_id
      t.text :shared_words
      t.text :words

      t.timestamps
    end
  end

  def self.down
    drop_table :tweets
  end
end
