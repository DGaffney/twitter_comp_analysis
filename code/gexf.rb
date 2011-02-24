require 'rubygems'
require 'dm-core'
require 'dm-aggregates'
require 'models/user'
require 'models/tweet'
require 'extensions/array'
require 'extensions/range'
DataMapper.finalize
require 'utils'

# Gexf.super_save("test_egypt-retweets_1-25_first_12", "style='retweet' and tweets.created_at between '2011-01-25 00:00:00' and '2011-01-25 12:00:00'", false, 60)Found 4057 edges.

module Gexf
  
  @all_my_bases = {"e" => "140kit_scratch_2", "t" => "140kit_scratch_1"}
  
  # start_node is original tweeter (tweeter being referenced)
  
  def self.save_with_weights(graph_name="", where="style='retweet'", behavior=false, offset=60, db="e")
    behavior = behavior ? "behavior_" : ""
    graph_name = "#{Time.now.strftime("%Y-%m-%d_%H-%M")}" if graph_name.empty?
    DataMapper.setup(:default, "mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/#{@all_my_bases[db]}")
    edges = DataMapper.repository(:default).adapter.select("select edges.edge_id, edges.style, edges.edge_id, edges.start_node, edges.end_node, #{behavior}tweets.pubdate from edges inner join #{behavior}tweets on edges.edge_id=#{behavior}tweets.twitter_id where #{where}")
    puts "Found #{edges.length} edges."
    edges_by_user = {}
    for edge in edges
      edges_by_user[edge.start_node] = {} if edges_by_user[edge.start_node].nil?
      edges_by_user[edge.start_node][edge.end_node] = [] if edges_by_user[edge.start_node][edge.end_node].nil?
      edges_by_user[edge.start_node][edge.end_node] << Time.parse(edge.pubdate.strftime).to_i
    end
    puts "Writing to graphs/#{graph_name}.gexf"
    Dir.mkdir("graphs") if !File.directory?("graphs")
    file = File.new("graphs/#{graph_name}.gexf", "w")
    file.write %{<gexf xmlns="http://www.gexf.net/1.1draft"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.gexf.net/1.1draft
                             http://www.gexf.net/1.1draft/gexf.xsd"
      version="1.1">
  <graph mode="dynamic" defaultedgetype="directed">
  	<attributes class="edge" mode="dynamic">
    <attribute id="weight" title="Weight" type="float"/>
  </attributes>
  <edges>\n}
    edges_by_user.each do |user_a, user_bs|
      user_bs.each do |user_b, times|
        file.write %{    <edge source="#{user_a}" target="#{user_b}" start="#{times.sort.first}" end="#{times.sort.last+offset}" weight="0">\n}
        file.write "      <attvalues>\n"
        ts = []
        times.sort.each {|t| ts += (t..t+offset).to_a }
        ts = ts.uniq.collect {|t| [t, ts.count(t)]}.sort {|x,y| x[0] <=> y[0]}
        lines = []
        weight = ts[0][1]
        start = ts[0][0]
        ts.each_index do |i|
          if i != 0 && (ts[i][1] != weight || ts[i-1][0] != ts[i][0]-1)
            lines << {:weight => weight, :start => start, :end => ts[i-1][0] }
            weight = ts[i][1]; start = ts[i][0]
          end
        end
        lines << {:weight => weight, :start => start, :end => ts.last[0] }
        for line in lines
          file.write %{        <attvalue for="weight" value="#{line[:weight]}" start="#{line[:start]}" end="#{line[:end]}"/>\n}
        end
    		file.write "      </attvalues>\n"
  		  file.write "      <slices>\n"
        for line in lines
          file.write %{        <slice start="#{line[:start]}" end="#{line[:end]}" />\n}
        end
    		file.write "      </slices>\n"
    		file.write "    </edge>\n"
      end
    end
    file.write "  </edges>\n"
    file.write "  </graph>\n"
    file.write "</gexf>"
    file.close
    puts "Saved graphs/#{graph_name}.gexf"
    return
  end
  
  def self.save_with_weights_and_colors(graph_name="", where="style='retweet'", behavior=false, offset=60, db="e")
    behavior = behavior ? "behavior_" : ""
    graph_name = "#{Time.now.strftime("%Y-%m-%d_%H-%M")}" if graph_name.empty?
    DataMapper.setup(:default, "mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/#{@all_my_bases[db]}")
    edges = DataMapper.repository(:default).adapter.select("select edges.edge_id, edges.style, edges.edge_id, edges.start_node, edges.end_node, #{behavior}tweets.pubdate from edges inner join #{behavior}tweets on edges.edge_id=#{behavior}tweets.twitter_id where #{where}")
    puts "Found #{edges.length} edges."
    users = edges.collect {|e| e.start_node } + edges.collect {|e| e.end_node }
    users.uniq!
    categories = {1 => {:label => "White", :r => rand(256), :g => rand(256), :b => rand(256)},
                  2 => {:label => "Black", :r => rand(256), :g => rand(256), :b => rand(256)},
                  3 => {:label => "Hispanic", :r => rand(256), :g => rand(256), :b => rand(256)},
                  4 => {:label => "Asian", :r => rand(256), :g => rand(256), :b => rand(256)},
                  5 => {:label => "Other", :r => rand(256), :g => rand(256), :b => rand(256)},
                  nil => {:label => "Not Categorized", :r => rand(256), :g => rand(256), :b => rand(256)}}
    user_category = {}
    csv = FasterCSV.parse(open('datasets/profile_categorization/source/egypt.csv').read)
    csv.each {|uc| user_category[uc[0]] = uc[1].to_i }
    edges_by_user = {}
    for edge in edges
      edges_by_user[edge.start_node] = {} if edges_by_user[edge.start_node].nil?
      edges_by_user[edge.start_node][edge.end_node] = [] if edges_by_user[edge.start_node][edge.end_node].nil?
      edges_by_user[edge.start_node][edge.end_node] << Time.parse(edge.pubdate.strftime).to_i
    end
    puts "Writing to graphs/#{graph_name}.gexf"
    Dir.mkdir("graphs") if !File.directory?("graphs")
    file = File.new("graphs/#{graph_name}.gexf", "w")
    file.write %{<?xml version="1.0" encoding="UTF-8"?>
<gexf xmlns="http://www.gexf.net/1.1draft" version="1.1" xmlns:viz="http://www.gexf.net/1.1draft/viz" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.gexf.net/1.1draft http://www.gexf.net/1.1draft/gexf.xsd">
  <meta lastmodifieddate="2010-12-30">
    <creator>Gephi 0.7</creator>
    <description></description>
  </meta>
  <graph defaultedgetype="directed" timeformat="double" mode="dynamic">
  <attributes class="node" mode="static">
    <attribute id="category" title="Category" type="string" />
  </attributes>
  <attributes class="edge" mode="dynamic">
    <attribute id="weight" title="Weight" type="float" />
  </attributes>
  <nodes>\n}
    for user in users
      # if user_category[user]
        category = categories[user_category[user]]
        # puts "#{user}: #{category.inspect} | #{user_category[user]}"
        file.write %{    <node id="#{user}" label="#{user}">
      <attvalues>
        <attvalue for="category" value="#{category[:label]}"></attvalue>
      </attvalues>
      <viz:color r="#{category[:r]}" g="#{category[:g]}" b="#{category[:b]}"></viz:color>
    </node>\n}
      # end
    end
    file.write "  </nodes>\n"
    file.write "  <edges>\n"
    edges_by_user.each do |user_a, user_bs|
      user_bs.each do |user_b, times|
        file.write %{    <edge source="#{user_a}" target="#{user_b}" start="#{times.sort.first}" end="#{times.sort.last+offset}" weight="0">\n}
        file.write "      <attvalues>\n"
        ts = []
        times.sort.each {|t| ts += (t..t+offset).to_a }
        ts = ts.uniq.collect {|t| [t, ts.count(t)]}.sort {|x,y| x[0] <=> y[0]}
        lines = []
        weight = ts[0][1]
        start = ts[0][0]
        ts.each_index do |i|
          if i != 0 && (ts[i][1] != weight || ts[i-1][0] != ts[i][0]-1)
            lines << {:weight => weight, :start => start, :end => ts[i-1][0] }
            weight = ts[i][1]; start = ts[i][0]
          end
        end
        lines << {:weight => weight, :start => start, :end => ts.last[0] }
        for line in lines
          file.write %{        <attvalue for="weight" value="#{line[:weight]}" start="#{line[:start]}" end="#{line[:end]}"/>\n}
        end
    		file.write "      </attvalues>\n"
  		  file.write "      <slices>\n"
        for line in lines
          file.write %{        <slice start="#{line[:start]}" end="#{line[:end]}" />\n}
        end
    		file.write "      </slices>\n"
    		file.write "    </edge>\n"
      end
    end
    file.write "  </edges>\n"
    file.write "  </graph>\n"
    file.write "</gexf>"
    file.close
    puts "Saved graphs/#{graph_name}.gexf"
    return
  end
  
  def self.save(graph_name="", where="style='retweet'", behavior=false, offset=60, db="e")
    behavior = behavior ? "behavior_" : ""
    graph_name = "#{Time.now.strftime("%Y-%m-%d_%H-%M")}" if graph_name.empty?
    DataMapper.setup(:default, "mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/#{@all_my_bases[db]}")
    edges = DataMapper.repository(:default).adapter.select("select edges.edge_id, edges.style, edges.edge_id, edges.start_node, edges.end_node, #{behavior}tweets.pubdate from edges inner join #{behavior}tweets on edges.edge_id=#{behavior}tweets.twitter_id where #{where}")
    puts "Found #{edges.length} edges."
    edges_by_user = {}
    for edge in edges
      edges_by_user[edge.start_node] = {} if edges_by_user[edge.start_node].nil?
      edges_by_user[edge.start_node][edge.end_node] = [] if edges_by_user[edge.start_node][edge.end_node].nil?
      edges_by_user[edge.start_node][edge.end_node] << Time.parse(edge.pubdate.strftime).to_i
    end
    puts "Writing to graphs/#{graph_name}.gexf"
    Dir.mkdir("graphs") if !File.directory?("graphs")
    file = File.new("graphs/#{graph_name}.gexf", "w")
    file.write %{<gexf xmlns="http://www.gexf.net/1.1draft"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.gexf.net/1.1draft
                             http://www.gexf.net/1.1draft/gexf.xsd"
      version="1.1">
  <graph mode="dynamic" defaultedgetype="directed">
  	<attributes class="edge" mode="dynamic">
    <attribute id="weight" title="Weight" type="float"/>
  </attributes>
  <edges>\n}
    edges_by_user.each do |user_a, user_bs|
      user_bs.each do |user_b, times|
        file.write %{    <edge source="#{user_a}" target="#{user_b}" start="#{times.sort.first}" end="#{times.sort.last+offset}" weight="0">\n}
        file.write "      <attvalues>\n"
        for time in times.uniq
          file.write %{        <attvalue for="weight" value="#{times.count(time)}" start="#{time}" end="#{time+offset}"/>\n}         
        end
    		file.write "      </attvalues>\n"
  		  file.write "      <slices>\n"
        for time in times.uniq
          file.write %{        <slice start="#{time}" end="#{time+offset}" />\n}
        end
    		file.write "      </slices>\n"
    		file.write "    </edge>\n"
      end
    end
    file.write "  </edges>\n"
    file.write "  </graph>\n"
    file.write "</gexf>"
    file.close
    puts "Saved graphs/#{graph_name}.gexf"
    return
  end
  
  
  
  
  
  def self.super_save(graph_name="", where="style='retweet'", behavior=false, offset=60, db="e")
    behavior = behavior ? "behavior_" : ""
    graph_name = "#{Time.now.strftime("%Y-%m-%d_%H-%M")}" if graph_name.empty?
    DataMapper.setup(:default, "mysql://gonkclub:cakebread@deebee.yourdefaulthomepage.com/#{@all_my_bases[db]}")
    edges = DataMapper.repository(:default).adapter.select("select edges.edge_id, edges.style, edges.edge_id, edges.start_node, edges.end_node, #{behavior}tweets.pubdate from edges inner join #{behavior}tweets on edges.edge_id=#{behavior}tweets.twitter_id where #{where}")
    puts "Found #{edges.length} edges."
    users = edges.collect {|e| e.start_node } + edges.collect {|e| e.end_node }
    users.uniq!
    # categories = {1 => {:label => "White", :r => rand(256), :g => rand(256), :b => rand(256)},
    #               2 => {:label => "Black", :r => rand(256), :g => rand(256), :b => rand(256)},
    #               3 => {:label => "Hispanic", :r => rand(256), :g => rand(256), :b => rand(256)},
    #               4 => {:label => "Asian", :r => rand(256), :g => rand(256), :b => rand(256)},
    #               5 => {:label => "Other", :r => rand(256), :g => rand(256), :b => rand(256)},
    #               nil => {:label => "Not Categorized", :r => rand(256), :g => rand(256), :b => rand(256)}}
    categories = {5=>{:b=>3, :r=>57, :g=>65, :label=>"Other"}, 1=>{:b=>137, :r=>190, :g=>37, :label=>"White"}, nil=>{:b=>23, :r=>219, :g=>211, :label=>"Not Categorized"}, 2=>{:b=>55, :r=>60, :g=>187, :label=>"Black"}, 3=>{:b=>193, :r=>65, :g=>119, :label=>"Hispanic"}, 4=>{:b=>29, :r=>225, :g=>2, :label=>"Asian"}}
    user_category = {}
    csv = FasterCSV.parse(open('datasets/profile_categorization/source/egypt.csv').read)
    csv.each {|uc| user_category[uc[0]] = uc[1].to_i }
    user_position = self.positions('graphs/1-25_positions.gexf')
    edges_by_user = {}
    for edge in edges
      edges_by_user[edge.start_node] = {} if edges_by_user[edge.start_node].nil?
      edges_by_user[edge.start_node][edge.end_node] = [] if edges_by_user[edge.start_node][edge.end_node].nil?
      edges_by_user[edge.start_node][edge.end_node] << Time.parse(edge.pubdate.strftime).to_i
    end
    puts "Writing to graphs/#{graph_name}.gexf"
    Dir.mkdir("graphs") if !File.directory?("graphs")
    file = File.new("graphs/#{graph_name}.gexf", "w")
    file.write %{<?xml version="1.0" encoding="UTF-8"?>
<gexf xmlns="http://www.gexf.net/1.1draft" version="1.1" xmlns:viz="http://www.gexf.net/1.1draft/viz" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.gexf.net/1.1draft http://www.gexf.net/1.1draft/gexf.xsd">
  <meta lastmodifieddate="2010-12-30">
    <creator>Gephi 0.7</creator>
    <description></description>
  </meta>
  <graph defaultedgetype="directed" timeformat="double" mode="dynamic">
  <attributes class="node" mode="static">
    <attribute id="category" title="Category" type="string" />
  </attributes>
  <attributes class="edge" mode="dynamic">
    <attribute id="weight" title="Weight" type="float" />
  </attributes>
  <nodes>\n}
    for user in users
      category = categories[user_category[user]]
      file.write %{    <node id="#{user}" label="#{user}">
      <attvalues>
        <attvalue for="category" value="#{category[:label]}"></attvalue>
      </attvalues>\n}
      if user_position[user]
        pos = user_position[user]
        file.write "      <viz:position x=\"#{pos[:x]}\" y=\"#{pos[:y]}\"></viz:position>\n"
      end
      file.write %{      <viz:color r="#{category[:r]}" g="#{category[:g]}" b="#{category[:b]}"></viz:color>
    </node>\n}
    end
    file.write "  </nodes>\n"
    file.write "  <edges>\n"
    edges_by_user.each do |user_a, user_bs|
      user_bs.each do |user_b, times|
        file.write %{    <edge source="#{user_a}" target="#{user_b}" start="#{times.sort.first}" end="#{times.sort.last+offset}" weight="0">\n}
        file.write "      <attvalues>\n"
        ts = []
        times.sort.each {|t| ts += (t..t+offset).to_a }
        ts = ts.uniq.collect {|t| [t, ts.count(t)]}.sort {|x,y| x[0] <=> y[0]}
        lines = []
        weight = ts[0][1]
        start = ts[0][0]
        ts.each_index do |i|
          if i != 0 && (ts[i][1] != weight || ts[i-1][0] != ts[i][0]-1)
            lines << {:weight => weight, :start => start, :end => ts[i-1][0] }
            weight = ts[i][1]; start = ts[i][0]
          end
        end
        lines << {:weight => weight, :start => start, :end => ts.last[0] }
        for line in lines
          file.write %{        <attvalue for="weight" value="#{line[:weight]}" start="#{line[:start]}" end="#{line[:end]}"/>\n}
        end
    		file.write "      </attvalues>\n"
  		  file.write "      <slices>\n"
        for line in lines
          file.write %{        <slice start="#{line[:start]}" end="#{line[:end]}" />\n}
        end
    		file.write "      </slices>\n"
    		file.write "    </edge>\n"
      end
    end
    file.write "  </edges>\n"
    file.write "  </graph>\n"
    file.write "</gexf>"
    file.close
    puts "Saved graphs/#{graph_name}.gexf"
    return
  end
  
  def self.positions(gexf_file)
    user_position = {}
    f = File.open(gexf_file, 'r')
    user = ""
    while (line = f.gets)
      case line.strip[1..5]
      when "node "
        user = line.scan(/id=\"(\w*)\"/)[0][0]
      when "viz:p"
        pos = line.scan(/x=\"([-\d\.]*)\" y=\"([-\d\.]*)\"/)[0]
        x = pos[0]
        y = pos[1]
        user_position[user] = {:x => x, :y => y}
      end
    end
    return user_position
  end
  
end