
Ishapi::Engine.routes.draw do

  root :to => 'application#home'
  post 'home', :to => 'application#home'

  resources :addresses

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
    get  'galleries', to: 'galleries#index'
    get  'newsitems', to: 'newsitems#index'
    get  'reports',   to: 'reports#index'
    get  'videos',    to: 'videos#index'
    post 'videos',    to: 'videos#index'
  end

  # N
  delete 'newsitems/:id', to: 'newsitems#destroy'

  post 'do_purchase', to: 'gameui#do_purchase' # @TODO: rename to just purchase, or destroy endpoint
  post 'payments', :to => 'payments#create'
  post 'payments2', :to => 'payments#create2' # @TODO: change
  get  'payments2', to: 'payments#create2'
  post 'payments/unlock', to: 'payments#unlock' # do_purchase
  post  'stripe_confirm', to: 'payments#stripe_confirm' # @TODO: test-drive

  get 'photos/view/:id', to: 'photos#show'
  get 'profiles/view/:username', :to => 'user_profiles#show'

  get 'reports', :to => 'reports#index'
  get 'reports/view/:slug', :to => 'reports#show'

  post 'stars/buy', to: 'gameui#buy_stars'

  ## 2022-02-12 moved to iron_warbler gem _vp_
  # resources "stock_watches"


  get 'test', to: 'application#test'

  post  'users/fb_sign_in',      to: 'users#fb_sign_in'
  get   'users/me',              to: 'users#account'
  post  'users/profile',         to: 'users#show' ## @TODO: change, this makes no sense
  post  'users/profile/update',  to: 'user_profiles#update'
  get   'users/profile',         to: 'users#show' # @TODO: only for testing! accessToken must be hidden
  match 'users/long_term_token', to: 'application#long_term_token', via: [ :get, :post ]
  devise_scope :user do
    post 'users/register', to: 'users/registrations#create'
    post 'users/login', to: 'users/sessions#create'
  end

  post 'v1/vote/:votee_class_name/:votee_id/:voter_id/:value', to: 'application#vote'

  resources :videos

end
