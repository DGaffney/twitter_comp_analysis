require 'rubygems'
require 'dm-core'
require 'dm-aggregates'
require 'models/user'
require 'models/tweet'
require 'extensions/array'
require 'extensions/range'
DataMapper.finalize
require 'utils'

module Gexf
  
  @all_my_bases = {"e" => "140kit_scratch_2", "t" => "140kit_scratch_1"}
  
  # start_node is original tweeter (tweeter being referenced)
  
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
  
end