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
  
  def graph_old
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
  
  def graph
    tweets = TweetsChosenThread.all(:conditions => {:thread_id => params[:id]})
    roots = []
    tweets.each {|t| roots += t.text.scan(/\brt @(\w+)/i).flatten }
    roots.collect! {|r| r.downcase }
    roots.uniq!
    root_pubdate = {}
    for root in roots
      root_tweet = TweetsChosenThread.first(:conditions => {:author => root, :thread_id => params[:id]})
      root_pubdate[root] = root_tweet.pubdate if !root_tweet.nil?
    end
    edges = []
    for tweet in tweets.sort {|x,y| x.pubdate <=> y.pubdate }
      tweet_roots = tweet.text.scan(/\brt @(\w+)/i).flatten.uniq
      most_recent_root = nil
      for root in tweet_roots
        # this is the fudgy part:
        root_pubdate[root] = tweet.pubdate if root_pubdate[root].nil?
        most_recent_root = root if (most_recent_root.nil? || root_pubdate[root] >= root_pubdate[most_recent_root])
      end
      edges << {:parent => most_recent_root, :child => tweet.author} if !most_recent_root.nil?
    end
    subthreads = {}
    edges.collect {|e| e[:parent] }.uniq.each {|p| subthreads[p] = [] }
    edges.each {|e| subthreads[e[:parent]] << e[:child] }
    threads = {}
    for parent in subthreads.keys.sort {|x,y| root_pubdate[y] <=> root_pubdate[x] }
      children = []
      for child in subthreads[parent]
        subchildren = subthreads.has_key?(child) ? subthreads[child] : []
        children << {:name => child, :id => child, :children => subchildren, :data => {}}
      end
      subthreads[parent] = children
    end
    oldest_parent = subthreads.keys.sort {|x,y| root_pubdate[x] <=> root_pubdate[y] }.first
    thread = {:name => oldest_parent, :id => oldest_parent, :children => subthreads[oldest_parent], :data => {}}
    
    @json = thread.to_json
    @actor_index = actor_index.to_json
    respond_to do |format|
      format.html
    end
  end
  
end
