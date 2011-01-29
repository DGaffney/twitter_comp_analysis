class Graph
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :style, String
end