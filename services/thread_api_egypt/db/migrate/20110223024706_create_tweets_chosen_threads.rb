class CreateTweetsChosenThreads < ActiveRecord::Migration
  def self.up
    create_table :tweets_chosen_threads do |t|
      t.text :text
      t.datetime :pubdate
      t.string :link
      t.string :author
      t.string :realname
      t.string :storyquery
      t.integer :thread_id
      t.text :words
      t.text :shared_words
      t.text :hashtags
      t.text :mentions
      t.datetime :datetime
      t.integer :twitter_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tweets_chosen_threads
  end
end
