class CreateDatasets < ActiveRecord::Migration
  def self.up
    create_table :datasets do |t|
      t.string :scrape_type
      t.datetime :start_time
      t.integer :length
      t.datetime :created_at
      t.datetime :updated_at
      t.boolean :scrape_finished
      t.string :instance_id
      t.string :params

      t.timestamps
    end
  end

  def self.down
    drop_table :datasets
  end
end
