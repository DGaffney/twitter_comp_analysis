class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.integer :p_cc
      t.integer :p_degree
      t.integer :p_twitter_id
      t.string :p_screen_name
      t.string :p_realname
      t.integer :p_type
      t.text :p_location
      t.text :p_description
      t.text :p_url
      t.string :p_language
      t.string :p_website_type
      t.text :p_notes
      t.text :p_followers
      t.text :p_following
      t.integer :p_following_count
      t.integer :p_follower_count
      t.text :p_in
      t.text :p_out
      t.integer :p_statuses_count
      t.text :p_picture
      t.datetime :p_created_at
      t.string :p_time_zone
      t.string :p_utc_offset
      t.string :p_verified
      t.integer :p_geo_enabled
      t.string :p_lang
      t.datetime :p_first_pubdate
      t.text :p_first_text
      t.integer :p_participation
      t.integer :p_protected
      t.datetime :last_update
      t.integer :times
      t.integer :erhardt
      t.integer :gilad
      t.integer :danah
      t.integer :mike
      t.text :p_edited_by

      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
