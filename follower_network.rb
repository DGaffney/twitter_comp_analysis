require 'rubygems'
require 'dm-core'
# require 'dm-migrations'
# require 'dm-aggregates'
require 'models/graph'
require 'models/edge'
require 'models/tweet'
require 'models/user'

DataMapper.finalize
require 'db'

require 'utils'

MAX_BATCH_SIZE = 100

def go(title='My Great Graph')
  g = Graph.create(:title => title, :style => 'follow')
  edges = []
  index = user_id_screenname_index
  user_ids = index.keys#.sort
  for user_id in user_ids
    followers = Utils.get_followers_from_id(user_id) & user_ids
    for follower in followers
      edges << Edge.new({:graph_id => g.id, :start_node => index[follower], :end_node => index[user_id], :style => 'follow'})
      if edges.length >= MAX_BATCH_SIZE
        bulk_insert_edges(edges)
        edges.clear
      end
    end
  end
  bulk_insert_edges(edges)
end

def user_id_screenname_index
  index = {}
  # users = User.all(:fields => ['twitter_id', 'screen_name'])
  users = DataMapper.repository(:default).adapter.select("SELECT twitter_id, screen_name FROM users")
  for user in users
    index[user.twitter_id] = user.screen_name
  end
  return index
end

def bulk_insert_edges(edges)
  return if edges.empty?
  puts "Bulk inserting #{edges.length} edges."
  sql = "INSERT INTO edges (graph_id, start_node, end_node, style) VALUES"
  for edge in edges
    values = [edge.graph_id, edge.start_node.inspect, edge.end_node.inspect, edge.style.inspect].join(", ")
    sql += " (#{edge.graph_id}, \'#{edge.start_node}\', \'#{edge.end_node}\', \'#{edge.style}\'),"
  end
  sql.chop!
  # puts sql.inspect
  DataMapper.repository(:default).adapter.execute(sql)
end

def fill_missing_user_ids
  u = User.first(:twitter_id => nil, :screen_name.not => [nil, ''])
  while !u.nil?
    user_id = Utils.user_id(u.screenname) || 0
    u.update(:twitter_id => user_id)
    u = User.first(:twitter_id => nil, :screen_name.not => [nil, ''])
  end
end

def fill_missing_screen_names
  User.all(:screen_name => '').update(:screen_name => nil)
  u = User.first(:screen_name => nil, :twitter_id.not => [nil, 0])
  while !u.nil?
    sn = Utils.screenname(u.user_id) || ''
    u.update(:screen_name => sn)
    u = User.first(:screen_name => nil, :twitter_id.not => [nil, 0])
  end
end

go("ball")