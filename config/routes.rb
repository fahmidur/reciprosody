Reciprosody2::Application.routes.draw do
  resources :corpora do
  	member do
  	  post :update
  		get :download
  		get :view_history

      get :manage_members
  		get :add_member
  		get :update_member
  		delete :remove_member

      get :comments
      get :add_comment
      get :remove_comment
      get :refresh_comments
      
      get :publications
  	end

  	get :autocomplete_language_name,	:on => :collection
  	get :autocomplete_license_name,		:on => :collection
  	get :autocomplete_user_name,	    :on => :collection
    get :autocomplete_corpus_name,    :on => :collection
    
  end

  match 'publications/new' => 'publications#new'

  resources :publications do
    member do
      get :manage_members
      get :add_member
      get :update_member
      delete :remove_member

      get :download
    end
  end
	
	
	#----authenticaton-----------------------
  devise_for :users, :controllers => {:registrations => "registrations"}
  
	match 'users'	=> 'users#index'
	
	#----maps to users controller-------------
	resource :user do
		member do
			get :invite
			post :invite_user
		end
	end
	
	
	#--------only a few static pages----------------------
	resources :pages
	root :to 			=> 'pages#index'
	match 'about' 		=> 'pages#about'
	match 'faq' 		=> 'pages#faq'
	match 'contact'		=> 'pages#contact'
	match 'perm'		=> 'pages#permission'
	match 'welcome'		=> 'pages#welcome'
	match 'how-to'		=> 'pages#how_to'
	
	match '/faq_submit'	=> 'pages#faq_submit', :via => :get
	match '/sug_submit' => 'pages#sug_submit', :via => :get
	#-----------------------------------------------------
	
	#------------Upload Controller-------------------------
	match 'upload_test' => 'upload#upload_test',	:via => :get
	match '/upload'		=> 'upload#ajx_upload',		:via => :post
	
	
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
