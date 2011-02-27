class BehaviorTweetsController < ApplicationController
  # GET /behavior_tweets
  # GET /behavior_tweets.xml
  def index
    @behavior_tweets = BehaviorTweet.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @behavior_tweets }
    end
  end

  # GET /behavior_tweets/1
  # GET /behavior_tweets/1.xml
  def show
    @behavior_tweet = BehaviorTweet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @behavior_tweet }
    end
  end

  # GET /behavior_tweets/new
  # GET /behavior_tweets/new.xml
  def new
    @behavior_tweet = BehaviorTweet.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @behavior_tweet }
    end
  end

  # GET /behavior_tweets/1/edit
  def edit
    @behavior_tweet = BehaviorTweet.find(params[:id])
  end

  # POST /behavior_tweets
  # POST /behavior_tweets.xml
  def create
    @behavior_tweet = BehaviorTweet.new(params[:behavior_tweet])

    respond_to do |format|
      if @behavior_tweet.save
        format.html { redirect_to(@behavior_tweet, :notice => 'BehaviorTweet was successfully created.') }
        format.xml  { render :xml => @behavior_tweet, :status => :created, :location => @behavior_tweet }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @behavior_tweet.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /behavior_tweets/1
  # PUT /behavior_tweets/1.xml
  def update
    @behavior_tweet = BehaviorTweet.find(params[:id])

    respond_to do |format|
      if @behavior_tweet.update_attributes(params[:behavior_tweet])
        format.html { redirect_to(@behavior_tweet, :notice => 'BehaviorTweet was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @behavior_tweet.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /behavior_tweets/1
  # DELETE /behavior_tweets/1.xml
  def destroy
    @behavior_tweet = BehaviorTweet.find(params[:id])
    @behavior_tweet.destroy

    respond_to do |format|
      format.html { redirect_to(behavior_tweets_url) }
      format.xml  { head :ok }
    end
  end
end
