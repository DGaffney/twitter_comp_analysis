require 'rubygems'
require 'dm-core'
require 'extensions/array'
require 'models/graph'
require 'models/edge'
require 'models/tweet'
require 'models/user'
DataMapper.finalize
require 'db'
require 'utils'

module FollowerNetwork
  
  MAX_BATCH_SIZE = 10
  THREAD_COUNT = 2#0
  
  def self.create(title='My Great Graph')
    threads = []
    g = Graph.create(:title => title, :style => 'follow')
    folder = "graph_#{g.id}"
    Dir.mkdir(folder)
    threads = []
    index = self.user_id_screenname_index
    user_ids = index.keys.sort
    for chunk in user_ids.chunk(THREAD_COUNT)
      threads << Thread.new(chunk) { |chunk|
        
        edges = []
        puts "Got a chunk of #{chunk.length}."
        for user_id in chunk
          followers = Utils.get_followers_from_id(user_id) & user_ids
          for follower in followers
            edges << Edge.new({:graph_id => g.id, :start_node => index[follower], :end_node => index[user_id], :style => 'follow'})
            if edges.length >= MAX_BATCH_SIZE
              # f.write(self.bulk_insert_edges(edges))
              bulk_insert_edges_file(folder, edges)
              edges.clear
            end
          end
        end
        # f.write(self.bulk_insert_edges(edges))
        bulk_insert_edges_file(folder, edges)
      }
    end
    threads.each { |t| t.join }
  end

  def self.user_id_screenname_index
    index = {}
    users = DataMapper.repository(:default).adapter.select("SELECT twitter_id, screen_name FROM users")
    for user in users
      index[user.twitter_id] = user.screen_name
    end
    return index
  end

  def self.bulk_insert_edges(edges)
    return if edges.empty?
    puts "Bulk inserting #{edges.length} edges."
    sql = "INSERT INTO edges (graph_id, start_node, end_node, style) VALUES"
    for edge in edges
      values = [edge.graph_id, edge.start_node.inspect, edge.end_node.inspect, edge.style.inspect].join(", ")
      sql += " (#{edge.graph_id}, \'#{edge.start_node}\', \'#{edge.end_node}\', \'#{edge.style}\'),"
    end
    sql.chop!
    sql = sql+";\n"
    # DataMapper.repository(:default).adapter.execute(sql)
    return sql
  end
  
  def self.bulk_insert_edges_file(folder, edges)
    f = File.new("#{folder}/#{edges.first.start_node}-#{edges.first.end_node}", "w")
    f.write(self.bulk_insert_edges(edges))
    f.close
  end
  
end

FollowerNetwork.create("ball")

# threads = []
# 1.upto(1) { |i|
#   threads << Thread.new() {
#     begin
#       puts "DSd"
#       edges = []
#       1.upto(10) {|x| edges << Edge.new({:graph_id => 0, :start_node => rand(10000), :end_node => rand(10000), :style => "ball"}) }
#       FollowerNetwork.bulk_insert_edges(edges) rescue "FUCK"
#       puts test.inspect
#     rescue Exception => e  
#       puts e.message  
#       puts e.backtrace.inspect  
#     end
#   }
# }
# `ls sql_calls`.split("\n").each {|h_wobs| DataMapper.repository(:default).adapter.execute(File.read("sql_calls/#{hat_wobs}"));`rm sql_calls/#{hat_wobs}`}