MetricsSite::Application.routes.draw do

  get 'status' => 'pages#status'
  get 'qc_config' => 'pages#qc_config'
  get 'app_config' => 'pages#app_config'
  get 'contact' => 'pages#contact'
  get 'beanplot' => 'pages#beanplot'
  get 'welcome' => 'pages#welcome'

  resources :metrics
  resources :msruns
  resources :comparisons #TODO: change this to hide the URLS.


  get 'comparisons/:id/*graph_path' => 'comparisons#get_graph_at_path'

  get 'alerts' => 'alerts#index'
  resource :alerts do 
    delete :remove_all, :to => "alerts#remove_all", :on => :collection
  end
  delete 'alerts/:id' => 'alerts#destroy', :as => 'alert'

  match 'chromatography/:id' => 'graph#show'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
  root to: "pages#home"

  # See how all your routes lay out with "rake routes"
end
