class EdgesController < ApplicationController
  # GET /edges
  # GET /edges.xml
  def index
    @edges = Edge.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @edges }
    end
  end

  # GET /edges/1
  # GET /edges/1.xml
  def show
    @edge = Edge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @edge }
    end
  end

  # GET /edges/new
  # GET /edges/new.xml
  def new
    @edge = Edge.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @edge }
    end
  end

  # GET /edges/1/edit
  def edit
    @edge = Edge.find(params[:id])
  end

  # POST /edges
  # POST /edges.xml
  def create
    @edge = Edge.new(params[:edge])

    respond_to do |format|
      if @edge.save
        format.html { redirect_to(@edge, :notice => 'Edge was successfully created.') }
        format.xml  { render :xml => @edge, :status => :created, :location => @edge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @edge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /edges/1
  # PUT /edges/1.xml
  def update
    @edge = Edge.find(params[:id])

    respond_to do |format|
      if @edge.update_attributes(params[:edge])
        format.html { redirect_to(@edge, :notice => 'Edge was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @edge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /edges/1
  # DELETE /edges/1.xml
  def destroy
    @edge = Edge.find(params[:id])
    @edge.destroy

    respond_to do |format|
      format.html { redirect_to(edges_url) }
      format.xml  { head :ok }
    end
  end
  
  def friends
    user = User.find_by_twitter_id(params[:id])
    thread_id_condition = params[:thread_id].nil? ? "" :  " and tweets_chosen_threads.thread_id = #{params[:thread_id]} "
    friends = ActiveRecord::Base.connection.execute("select users.twitter_id from users inner join edges on users.screen_name = edges.start_node join tweets_chosen_threads on tweets_chosen_threads.author = edges.start_node where edges.style = 'follow' and edges.end_node = '#{user.screen_name}' #{thread_id_condition}").all_hashes.collect{|r| r["twitter_id"].to_i}
    render :json => friends.to_json
  end
  
  def followers
    user = User.find_by_twitter_id(params[:id])
    thread_id_condition = params[:thread_id].nil? ? "" :  " and tweets_chosen_threads.thread_id = #{params[:thread_id]} "
    friends = ActiveRecord::Base.connection.execute("select users.twitter_id from users inner join edges on users.screen_name = edges.end_node join tweets_chosen_threads on tweets_chosen_threads.author = edges.end_node where edges.style = 'follow' and edges.start_node = '#{user.screen_name}' #{thread_id_condition}").all_hashes.collect{|r| r["twitter_id"].to_i}    
    render :json => friends.to_json
  end
end
