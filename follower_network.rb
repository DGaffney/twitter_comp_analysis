require 'rubygems'
require 'dm-core'
# require 'dm-migrations'
# require 'dm-aggregates'
require 'extensions/array'
require 'models/graph'
require 'models/edge'
require 'models/tweet'
require 'models/user'

DataMapper.finalize

require 'db'
require 'utils'

module FollowerNetwork
  
  MAX_BATCH_SIZE = 500
  THREAD_COUNT = 20
  
  def self.create(title='My Great Graph')
    threads = []
    g = Graph.create(:title => title, :style => 'follow')
    threads = []
    index = self.user_id_screenname_index
    user_ids = index.keys#.sort
    for chunk in user_ids.chunk(THREAD_COUNT)
      threads << Thread.new(chunk) { |chunk|
        edges = []
        puts "Got a chunk of #{chunk.length}."
        for user_id in chunk
          followers = Utils.get_followers_from_id(user_id) & user_ids
          for follower in followers
            edges << Edge.new({:graph_id => g.id, :start_node => index[follower], :end_node => index[user_id], :style => 'follow'})
            if edges.length >= MAX_BATCH_SIZE
              self.bulk_insert_edges(edges)
              edges.clear
            end
          end
        end
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
    DataMapper.repository(:default).adapter.execute(sql)
  end
  
end

FollowerNetwork.create("ball")