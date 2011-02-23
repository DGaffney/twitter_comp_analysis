class ChosenThreadsController < ApplicationController
  # GET /chosen_threads
  # GET /chosen_threads.xml
  def index
    @chosen_threads = ChosenThread.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @chosen_threads }
    end
  end

  # GET /chosen_threads/1
  # GET /chosen_threads/1.xml
  def show
    @chosen_thread = ChosenThread.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @chosen_thread }
    end
  end

  # GET /chosen_threads/new
  # GET /chosen_threads/new.xml
  def new
    @chosen_thread = ChosenThread.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @chosen_thread }
    end
  end

  # GET /chosen_threads/1/edit
  def edit
    @chosen_thread = ChosenThread.find(params[:id])
  end

  # POST /chosen_threads
  # POST /chosen_threads.xml
  def create
    @chosen_thread = ChosenThread.new(params[:chosen_thread])

    respond_to do |format|
      if @chosen_thread.save
        format.html { redirect_to(@chosen_thread, :notice => 'ChosenThread was successfully created.') }
        format.xml  { render :xml => @chosen_thread, :status => :created, :location => @chosen_thread }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @chosen_thread.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /chosen_threads/1
  # PUT /chosen_threads/1.xml
  def update
    @chosen_thread = ChosenThread.find(params[:id])

    respond_to do |format|
      if @chosen_thread.update_attributes(params[:chosen_thread])
        format.html { redirect_to(@chosen_thread, :notice => 'ChosenThread was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @chosen_thread.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /chosen_threads/1
  # DELETE /chosen_threads/1.xml
  def destroy
    @chosen_thread = ChosenThread.find(params[:id])
    @chosen_thread.destroy

    respond_to do |format|
      format.html { redirect_to(chosen_threads_url) }
      format.xml  { head :ok }
    end
  end
end
