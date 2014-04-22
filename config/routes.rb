Reciprosody2::Application.routes.draw do
  resources :corpora do
  	member do
  	  post :update
  		get :download
      get :browse
        get :single_download
        post :single_upload
        delete :single_delete
        post :single_rename
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
        delete :delete_publication_rel
        get    :add_publication_rel
        get    :update_publication_rel
      get :tools
        delete :delete_tool_rel
        get    :add_tool_rel
        get    :update_tool_rel
  	end

  	get :autocomplete_language_name,	:on => :collection
  	get :autocomplete_license_name,		:on => :collection
  	get :autocomplete_user_name,	    :on => :collection
    get :autocomplete_corpus_name,    :on => :collection
    get :autocomplete_tool_corpus_relationship_name, :on => :collection
    get :autocomplete_publication_corpus_relationship_name, :on => :collection
    get :autocomplete_tool_publication_relationship_name, :on => :collection
  end

  resources :institutions do
    member do
    end
    get :autocomplete_institution_name, :on => :collection
  end

  resources :tools do
    member do
      get :download

      get :corpora
        get :add_corpus_rel
        get :update_corpus_rel
        delete :delete_corpus_rel

      get :publications
        get :add_publication_rel
        get :update_publication_rel
        delete :delete_publication_rel

      get :manage_members
      get :add_member
      get :update_member
      delete :remove_member
    end

    get :autocomplete_tool_name, :on => :collection
    get :autocomplete_tool_keyword_name, :on => :collection
    get :autocomplete_programming_language_name, :on => :collection
  end

  resources :publications do
    member do
      get :manage_members
      get :add_member
      get :update_member
      delete :remove_member


      get :corpora
        get :add_corpus_rel
        get :update_corpus_rel
        delete :delete_corpus_rel

        
      get :tools
        get :add_tool_rel
        get :update_tool_rel
        delete :delete_tool_rel
      
      
      get :download
    end

    get :autocomplete_publication_keyword_name, :on => :collection
    get :autocomplete_publication_name, :on => :collection
  end


	
	
	#----authenticaton-----------------------
  devise_for :users, :controllers => {:registrations => "registrations"}

	resources :users, :constraints => {:id => /\d+|.+\@.+/} do
    collection do
      get :index              #user home page
      get :mixed_search       #search users
    end
    
    member do
      get :show
    end
  end

	resource :user do
		member do
			get :invite


      get :inbox                    #users_controller#inbox
      get :inbox_delete             #users_controller#inbox_delete
      get :send_message             #users_controller#send_message
      get :inbox_get                #users_controller#inbox_get
      get :inbox_mark_read          #users_controller#inbox_mark_read
      get :inbox_mark_unread        #users_controller#inbox_mark_unread
      get :inbox_restore            #users_controller#inbox_restore

      get :set_prop                 #users_controller#set_prop
      get :add_inst_rel             #users_controller#add_inst_rel
      get :remove_inst_rel          #users_controller#remove_inst_rel

      get :update_gravatar_email    #users_controller#update_gravatar_email
      
			post :invite_user

      # get :edit_avatar # no longer used and does not work
		end
	end

  #---maps to admin controller---
  resources :admins do
    collection do
      get :request_a_key
      post :process_request_form
      get :wait
    end
  end

  if Rails.env.development?
    mount AdminsMailer::Preview => 'admins_mail_view'
    mount UsersMailer::Preview => 'users_mail_view'
  end

  match '/graphics/one' => 'graphics#one', :via => :get
	
	
	#--------only a few static pages----------------------
	resources :pages
	root :to           => 'pages#index', :via => :get
	match 'about'      => 'pages#about', :via => :get
	match 'faq'        => 'pages#faq', :via => :get
	match 'contact'    => 'pages#contact', :via => :get
	match 'perm'       => 'pages#permission', :via => :get
	match 'welcome'    => 'pages#welcome', :via => :get
	match 'how-to'     => 'pages#how_to', :via => :get
	match '/faq_submit'	=> 'pages#faq_submit', :via => :get
	match '/sug_submit' => 'pages#sug_submit', :via => :get
	#-----------------------------------------------------
	
	#------------Upload Controller-------------------------
	match '/upload_test' => 'upload#upload_test',	:via => :get
	match '/upload'		=> 'upload#ajx_upload',		:via => :post

  match '/resumable_test' => 'resumable#resumable_test', :via => :get
  match '/resumable_upload' => 'resumable#post_resumable_upload', :via => :post
  match '/resumable_upload' => 'resumable#get_resumable_upload', :via => :get

  match '/resumable_upload_ready' => 'resumable#resumable_upload_ready', :via => :get
  match '/resumable_upload_combine' => 'resumable#resumable_upload_combine', :via => :get
  match '/resumable_upload_clean' => 'resumable#resumable_upload_clean', :via => :get
  match '/resumable_upload_abort' => 'resumable#resumable_upload_abort', :via => :get
  match '/resumable_upload_savestate' => 'resumable#resumable_upload_savestate', :via => :get
  match '/resumable_upload_deletestate' => 'resumable#resumable_upload_deletestate', :via => :get

  match '/resumable_list' => 'resumable#resumable_list', :via => :get
	
	
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
