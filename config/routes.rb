Ishapi::Engine.routes.draw do
  root :to => 'application#home'
  post 'home', :to => 'application#home'

  resources :addresses

  get 'cities',                :to => 'cities#index'
  get 'cities/view/:cityname', :to => 'cities#show'
  get 'cities/features',       :to => 'cities#features'

  get 'events/view/:eventname',      :to => 'events#show'

  get  'galleries',                   :to => 'galleries#index'
  post 'galleries',                   :to => 'galleries#index'
  get  'galleries/view/:slug', :to => 'galleries#show'
  post 'galleries/view/:slug', :to => 'galleries#show'

  post 'invoices/search', :to => 'invoices#search'

  get 'maps', to: 'maps#index'
  get 'maps/view/:slug', to: 'maps#show'
  get 'markers/view/:slug', to: 'maps#show_marker'
  match  "/my/account", to: "users#account", via: [ :get, :post ]
  namespace :my do
    get 'galleries', to: 'galleries#index'
    get 'newsitems', to: 'newsitems#index'
    get  'reports',  to: 'reports#index'
    get  'videos',   to: 'videos#index'
    post 'videos',   to: 'videos#index'
  end

  post 'do_purchase', to: 'gameui#do_purchase' # @TODO: rename to just purchase, or destroy endpoint
  post 'payments', :to => 'payments#create'
  post 'payments2', :to => 'payments#create2' # @TODO: change
  get  'payments2', to: 'payments#create2'
  post 'payments/unlock', to: 'payments#unlock' # do_purchase
  post  'stripe_confirm', to: 'payments#stripe_confirm' # @TODO: test-drive

  get 'profiles/view/:username', :to => 'user_profiles#show'

  get 'reports', :to => 'reports#index'
  get 'reports/view/:slug', :to => 'reports#show'

  get  'sites/view/:domain',                            :to => 'sites#show',      :constraints => { :domain => /[^\/]+/ }
  post 'sites/view/:domain',                            :to => 'sites#show',      :constraints => { :domain => /[^\/]+/ }
  get  'sites/view/:domain/newsitems/:newsitems_page',  :to => 'newsitems#index', :constraints => { :domain => /[^\/]+/ }
  get  'sites/view/:domain/reports',                    :to => 'reports#index',   :constraints => { :domain => /[^\/]+/ }
  get  'sites/view/:domain/reports/page/:reports_page', :to => 'reports#index',   :constraints => { :domain => /[^\/]+/ }
  get  'sites/view/:domain/tags',                       :to => 'tags#index',      :constraints => { :domain => /[^\/]+/ }

  post 'stars/buy', to: 'gameui#buy_stars'

  ## 2022-02-12 moved to iron_warbler gem _vp_
  # resources "stock_watches"

  get 'tags/view/:slug', :to => 'tags#show'
  get 'test', to: 'application#test'

  post  'users/fb_sign_in',      to: 'users#fb_sign_in'
  get   'users/me',              to: 'users#account'
  post  'users/profile',         to: 'users#show'
  post  'users/profile/update',  to: 'users#update'
  get   'users/profile',         to: 'users#show' # @TODO: only for testing! accessToken must be hidden
  match 'users/long_term_token', to: 'application#long_term_token', via: [ :get, :post ]
  post  'users/login',           to: 'users#login'
  post  'users',                 to: 'users#create'

  get 'venues', :to => 'venues#index'
  get 'venues/view/:venuename', :to => 'venues#show'

  resources :videos

end
