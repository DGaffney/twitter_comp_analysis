class CreateEdges < ActiveRecord::Migration
  def self.up
    create_table :edges do |t|
      t.integer :graph_id
      t.string :start_node
      t.string :end_node
      t.integer :edge_id
      t.string :style

      t.timestamps
    end
  end

  def self.down
    drop_table :edges
  end
end
