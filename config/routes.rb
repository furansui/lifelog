Lifelog::Application.routes.draw do
  root 'home#index'
  get "home/index"

  get "time/categories"
  get "time/list"
  match "time/timelogs" => "time#timelogs", via: [:get, :post]
  match "time/categories" => "time#categories", via: [:get, :post]


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  resources :clothes do
    collection {
      post :wear_today
    }
  end

  resources :healths
  resources :health_categories
  
  resources :categories do
    collection { 
      post :import 
    }
  end
  resources :timelogs do
    collection { 
      post :import 
      post :delete
      post :delete_multiple
    }
  end

  namespace :api do
    namespace :v2 do
      resources :timelogs
    end
  end

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
end
