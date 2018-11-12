Rails.application.routes.draw do
  get "/vehicle_configs", to: redirect("/research", status: 302)
  get '/vehicle_configs/:id', to: redirect('/research/%{id}', status: 302)
  
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  authenticate :user, lambda { |u| u.is_super_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  # root to: "admin"
  # mount Commontator::Engine => '/commontator'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".
  # You can have the root of your site routed with "root"
  root "vehicle_configs_admin/admin#index"
  get '/workbench' => 'workbench#index'
  get "/sitemap.xml" => "sitemap#index", :format => "xml", :as => :sitemap
  get '/lookup' => "vehicle_lookups_admin/admin#new"
  get '/garage' => "user_vehicles_admin/admin#index"
  get "/vehicles" => "vehicle_configs_admin/admin#index"
  get "/vehicles/make/:q" => "vehicle_configs_admin/admin#index", as: "vehicles_make"
  get "/vehicles/top" => "vehicle_configs_admin/admin#index", as: "vehicles_top", default: { order: "desc", sort: "cached_votes_score"}
  get "/vehicles/:id" => "vehicle_configs_admin/admin#show", as: "vehicles_show"

  # mount Thredded::Engine => '/discuss'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  # get '/:id' => "shortener/shortened_urls#show"
end
