class TweetsChosenThreadsController < ApplicationController
  require 'lib/hash.rb'
  # GET /tweets_chosen_threads
  # GET /tweets_chosen_threads.xml
  def index
    # @tweets_chosen_threads = TweetsChosenThread.all
    @thread_ids = ActiveRecord::Base.connection.execute("select distinct thread_id from tweets_chosen_threads").all_hashes.collect {|h| h["thread_id"].to_i }

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @thread_ids }
    end
  end

  # GET /tweets_chosen_threads/1
  # GET /tweets_chosen_threads/1.xml
  def show
    @tweets_chosen_thread = TweetsChosenThread.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tweets_chosen_thread }
    end
  end

  # GET /tweets_chosen_threads/new
  # GET /tweets_chosen_threads/new.xml
  def new
    @tweets_chosen_thread = TweetsChosenThread.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tweets_chosen_thread }
    end
  end

  # GET /tweets_chosen_threads/1/edit
  def edit
    @tweets_chosen_thread = TweetsChosenThread.find(params[:id])
  end

  # POST /tweets_chosen_threads
  # POST /tweets_chosen_threads.xml
  def create
    @tweets_chosen_thread = TweetsChosenThread.new(params[:tweets_chosen_thread])

    respond_to do |format|
      if @tweets_chosen_thread.save
        format.html { redirect_to(@tweets_chosen_thread, :notice => 'TweetsChosenThread was successfully created.') }
        format.xml  { render :xml => @tweets_chosen_thread, :status => :created, :location => @tweets_chosen_thread }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tweets_chosen_thread.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tweets_chosen_threads/1
  # PUT /tweets_chosen_threads/1.xml
  def update
    @tweets_chosen_thread = TweetsChosenThread.find(params[:id])

    respond_to do |format|
      if @tweets_chosen_thread.update_attributes(params[:tweets_chosen_thread])
        format.html { redirect_to(@tweets_chosen_thread, :notice => 'TweetsChosenThread was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tweets_chosen_thread.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tweets_chosen_threads/1
  # DELETE /tweets_chosen_threads/1.xml
  def destroy
    @tweets_chosen_thread = TweetsChosenThread.find(params[:id])
    @tweets_chosen_thread.destroy

    respond_to do |format|
      format.html { redirect_to(tweets_chosen_threads_url) }
      format.xml  { head :ok }
    end
  end
  
  def thread_response
    result = thread_hash.to_json
    render :json => result
  end
  
  def graph
    @json = thread_json
    @actor_index = actor_index.to_json
    respond_to do |format|
      format.html
    end
  end

  def thread_hash
    # thread_ids = ActiveRecord::Base.connection.execute("select distinct(thread_id) from tweets_chosen_threads").all_hashes.collect{|x| x["thread_id"]}
    # thread_ids.each do |thread_id|
    #   puts thread_id
    #   params = {:id => thread_id}
      result = Rails.cache.fetch("threads_tree_#{params[:id]}"){
        root = TweetsChosenThread.find(:first, :conditions => {:thread_id => params[:id]}, :order => "pubdate asc")
        tweet = Tweet.find_by_twitter_id(root.twitter_id) || TweetsChosenThread.tweet_data(root.twitter_id)
        in_reply_to_status_id = tweet.class==Array ? tweet.first["in_reply_to_status_id"]||tweet.first["retweeted_status"]&&tweet.first["retweeted_status"]["id"] : tweet.in_reply_to_status_id
        if in_reply_to_status_id && in_reply_to_status_id != 0
          root = TweetsChosenThread.tweet_data(in_reply_to_status_id)
          in_reply_to_status_id = root.class==Array ? root.first["in_reply_to_status_id"]||root.first["retweeted_status"]&&root.first["retweeted_status"]["id"] : root.in_reply_to_status_id
          while in_reply_to_status_id && in_reply_to_status_id != 0 
            root = TweetsChosenThread.tweet_data(in_reply_to_status_id)
            in_reply_to_status_id = root.class==Array ? root.first["in_reply_to_status_id"]||root.first["retweeted_status"]&&root.first["retweeted_status"]["id"] : root.in_reply_to_status_id
          end
        end
        TweetsChosenThread.return_child_js(root, params[:id])
      }
    # end
    return result
  end
  
  def actor_paths
    # result = Rails.cache.fetch("actor_paths_#{params[:id]}"){
    result = {}
    if params[:id]!=0
      threads = thread_hash
      actor_type_index = actor_index
      scrubbed_threads = {}
      scrubbed_threads[threads["name"]] = actor_path(threads["children"])
      paths = scrubbed_threads.flatify("^^").keys.collect{|keys| keys.split("^^").collect{|u| Profile.classification(u)}.join("")}
      paths.each do |path|
        result[path] = 0 if result[path].nil?
        result[path]+=1
      end
    else
      thread_ids = ActiveRecord::Base.connection.execute("select distinct(thread_id) from tweets_chosen_threads").all_hashes.collect{|x| x["thread_id"]}
      thread_ids.each do |thread_id|
        params = {:id => thread_id}
        threads = Rails.cache.fetch("threads_tree_#{params[:id]}")
        actor_type_index = actor_index
        scrubbed_threads = {}
        scrubbed_threads[threads["name"]] = actor_path(threads["children"])
        paths = scrubbed_threads.flatify("^^").keys.collect{|keys| keys.split("^^").collect{|u| Profile.classification(u)}.join("")}
        paths.each do |path|
          result[path] = 0 if result[path].nil?
          result[path]+=1
        end
      end
    end
      # result      
    # }
    render :json => result.to_json
  end
  
  def actor_path(children)
    results = {}
    children.each do |child|
      results[child["name"]] = actor_path(child["children"])
    end
    results = [] if results.empty?
    return results
  end
  
  def actor_breakdown
    thread = thread_hash
    result = {}
    actor_type_index = actor_index
    result[:originator] = {:screen_name => thread["name"], :actor_type => actor_type_index[thread["name"].downcase]}
    users = all_children(thread).collect {|u| u.downcase }
    users.delete(thread["name"])
    actor_type_breakdown = {}
    for user in users
      actor_type = actor_type_index[user] || "uncategorized"
      if actor_type_breakdown.has_key?(actor_type)
        actor_type_breakdown[actor_type][:count] += 1
      else
        actor_type_breakdown[actor_type] = {:count => 1}
      end
    end
    total = users.length.to_f
    actor_type_breakdown.each {|k,v| actor_type_breakdown[k][:percent] = (v[:count] / total)}
    result[:actor_types] = actor_type_breakdown
    render :json => result.to_json
  end

  def actor_index
    r = ActiveRecord::Base.connection.execute("select p_screen_name, p_type from profiles").all_hashes
    index = {}
    r.each {|h| index[h["p_screen_name"].downcase] = h["p_type"].to_i }
    return index
  end
  
  def all_children(hash)
    children = []
    children << hash["name"]
    hash["children"].each {|h| children += all_children(h) }
    return children.uniq
  end
  
  def thread_json
    return thread_hash.to_json
  end

  def root_tweet(thread_id)
    root = TweetsChosenThread.find(:first, :conditions => {:thread_id => thread_id}, :order => "pubdate asc")
    tweet = TweetsChosenThread.tweet_data(root.twitter_id)
    in_reply_to_status_id = tweet.class==Array ? tweet.first["in_reply_to_status_id"]||tweet.first["retweeted_status"]&&tweet.first["retweeted_status"]["id"] : tweet.in_reply_to_status_id
    if in_reply_to_status_id && in_reply_to_status_id != 0
      root = TweetsChosenThread.tweet_data(in_reply_to_status_id)
      in_reply_to_status_id = root.class==Array ? root.first["in_reply_to_status_id"]||root.first["retweeted_status"]&&root.first["retweeted_status"]["id"] : root.in_reply_to_status_id
      while in_reply_to_status_id && in_reply_to_status_id != 0 
        root = TweetsChosenThread.tweet_data(in_reply_to_status_id)
        in_reply_to_status_id = root.class==Array ? root.first["in_reply_to_status_id"]||root.first["retweeted_status"]&&root.first["retweeted_status"]["id"] : root.in_reply_to_status_id
      end
    end
    return root
  end
  
  def find_children(root_name, root_twitter_id, edges, included_ids=[])
    result = {}
    result["id"] = root_twitter_id
    result["name"] = root_name
    result["data"] = {}
    children_data = []
    children = root_edges = edges.select{|e| e[:parent]==root_name&&e[:irtsi]==root_twitter_id}
    children.each do |child|
      if !included_ids.include?(child[:id])
        included_ids << child[:id]
        children_data << find_children(child[:child], child[:id], edges, included_ids=[])
      end
    end
    result["children"] = children_data
    return result
  end
  
  def graph_new
    debugger
    result = Rails.cache.fetch("graph_new_#{params[:id]}"){
      tweets = TweetsChosenThread.all(:conditions => {:thread_id => params[:id]})
      tweet_in_reply_to_status_ids = {}
      Tweet.find(:all, :conditions => {:twitter_id => tweets.collect{|x| x.twitter_id}}).collect{|t| tweet_in_reply_to_status_ids[t.twitter_id] = t.in_reply_to_status_id}
      root = root_tweet(params[:id])
      edges = []
      tweets.each do |tweet|
        twitter_id = tweet.class==Array ? tweet.first["id"] : tweet.twitter_id
        in_reply_to_status_id = tweet_in_reply_to_status_ids[twitter_id]
        child_screen_name = tweet.author
        child_twitter_id = tweet.twitter_id
        while !in_reply_to_status_id.nil? && in_reply_to_status_id != 0 
          parent = TweetsChosenThread.tweet_data(in_reply_to_status_id)
          parent_screen_name = parent.class==Array ? parent.last["screen_name"] : parent.screen_name
          edge = {:parent => parent_screen_name, :child => child_screen_name, :id => child_twitter_id, :irtsi => in_reply_to_status_id}
          edges << edge if !edges.include?(edge)
          in_reply_to_status_id = parent.class==Array ? parent.first["in_reply_to_status_id"]||parent.first["retweeted_status"]&&parent.first["retweeted_status"]["id"] : parent.in_reply_to_status_id
          tweet = parent
          child_screen_name = tweet.class==Array ? tweet.last["screen_name"] : tweet.author
          child_twitter_id = tweet.class==Array ? tweet.first["id"] : tweet.twitter_id
        end
      end
      result = {}
      root_name = root.class==Array ? root.last["screen_name"] : root.author
      root_twitter_id = root.class==Array ? root.first["id"] : root.twitter_id
      result = {}
      result["name"] = root_name
      result["id"] = root_twitter_id
      result["data"] = root_twitter_id
      result["children"] = find_children(root_name, root_twitter_id, edges)
      result
    }
    @json = result.to_json
    @actor_index = actor_index.to_json
    respond_to do |format|
      format.html
    end
  end
  
end
