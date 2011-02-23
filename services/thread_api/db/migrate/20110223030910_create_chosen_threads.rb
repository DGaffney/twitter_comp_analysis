class CreateChosenThreads < ActiveRecord::Migration
  def self.up
    create_table :chosen_threads do |t|
      t.integer :count
      t.integer :source_type
      t.text :first_text
      t.string :identified
      t.text :mentioned
      t.datetime :start
      t.datetime :end
      t.text :notes
      t.integer :duration
      t.string :duration_str

      t.timestamps
    end
  end

  def self.down
    drop_table :chosen_threads
  end
end
