ActionController::Routing::Routes.draw do |map|
  map.thread_api "/threads/:id.js", :controller => "tweets_chosen_threads", :action => "thread_response"
  map.thread_graph "/graph/threads/:id", :controller => "tweets_chosen_threads", :action => "graph"
  map.thread_graph2 "/graph2/threads/:id", :controller => "tweets_chosen_threads", :action => "graph_new"
  map.friends "/friends/:id.json", :controller => "edges", :action => "friends"
  map.followers "/followers/:id.json", :controller => "edges", :action => "followers"
  map.actor_breakdown "/threads/actors/:id.json", :controller => "tweets_chosen_threads", :action => "actor_breakdown"
  map.actor_paths "/threads/actor_paths/:id.json", :controller => "tweets_chosen_threads", :action => "actor_paths"
  
  map.thread "/threads", :controller => "tweets_chosen_threads", :action => "index"
  
  # map.resources :users
  # 
  # map.resources :tweets
  # 
  # map.resources :profiles
  # 
  # map.resources :chosen_threads
  # 
  # map.resources :graphs
  # 
  # map.resources :edges
  # 
  # map.resources :datasets
  # 
  # map.resources :behavior_tweets
  # 
  # map.resources :tweets_chosen_threads

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
