class Graph
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :style, String
  
  def self.save_new_data_set(data_set, name, database=:default)
    graph = Graph.new
    graph.title = name
    graph.save
    query = "INSERT INTO `graph_points` (`key`, `value`, `graph_id`,`created_at`) VALUES "
    data_set.each do |graph_point|
      query+="('#{graph_point["key"]}','#{graph_point["value"]}',#{graph.id}, '#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}'),"
    end
    query=query.chop
    DataMapper.repository(database).adapter.execute(query)
  end
end