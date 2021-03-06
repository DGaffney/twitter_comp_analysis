require 'rubygems'
require 'dm-core'
require 'extensions/array'
require 'models/graph'
require 'models/edge'
require 'models/tweet'
require 'models/user'
DataMapper.finalize
#require 'db'
DataMapper.setup(:default, 'mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/140kit_scratch_1')
require 'utils'

module FollowerNetwork
  
  MAX_BATCH_SIZE = 1000
  THREAD_COUNT = 100
  
  def self.create(title='My Great Graph')
    threads = []
    g = Graph.create(:title => title, :style => 'follow')
    folder = "graph_#{g.id}"
    puts "\n\nGraph id: #{g.id}\n\n"
    Dir.mkdir(folder)
    threads = []
    index = self.user_id_screenname_index
    user_ids = index.keys.sort
    users_to_do = index.values - DataMapper.repository(:default).adapter.select("SELECT DISTINCT end_node FROM edges WHERE style='follow'")
    puts "Found #{user_ids.length} users."
    puts "There are #{users_to_do.length} users left to do."
    for chunk in users_to_do.chunk(THREAD_COUNT)
      threads << Thread.new(chunk) { |chunk|
        
        edges = []
        puts "Got a chunk of #{chunk.length}."
        for user in chunk
          followers = Utils.get_followers_from_screen_name(user) & user_ids
          for follower in followers
            edges << Edge.new({:graph_id => g.id, :start_node => index[follower], :end_node => user, :style => 'follow'})
            if edges.length >= MAX_BATCH_SIZE
              # f.write(self.bulk_insert_edges(edges))
              self.bulk_insert_edges_file(folder, edges)
              edges.clear
            end
          end
        end
        # f.write(self.bulk_insert_edges(edges))
        self.bulk_insert_edges_file(folder, edges)
      }
    end
    threads.each { |t| t.join }
    puts "\n\nGraph id: #{g.id}\n\n"
    return g.id
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
  
  def self.bulk_insert_folder(folder)
    files = `ls #{folder}`.split("\n")
    puts "Found #{files.length} raw sql files to execute."
    files.each {|f| print "#{f} "; DataMapper.repository(:default).adapter.execute(File.read("#{folder}/#{f}")) }
    puts "Bulk inserted."
  end
  
end

FollowerNetwork.create("followers")
puts "Remember to run FollowerNetwork.bulk_insert_folder(graph_id) !!!"

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
