class Edge
  include DataMapper::Resource
  property :id, Serial
  property :graph_id, Integer
  property :start_node, String
  property :end_node, String
  property :edge_id, Integer
  property :time, DateTime
  property :style, String
end