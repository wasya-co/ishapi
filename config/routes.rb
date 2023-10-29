
Ishapi::Engine.routes.draw do

  root         to: 'application#home'
  post 'home', to: 'application#home'

  ## E

  post 'email_messages',    to: 'email_messages#receive'
  get 'email_messages/:id', to: 'email_messages#show', as: :email_message

  get 'email_contexts/summary', to: 'email_contexts#summary'

  delete 'email_conversations',                  to: 'email_conversations#delete'
  post   'email_conversations/addtag',           to: 'email_conversations#addtag'
  post   'email_conversations/addtag/:emailtag', to: 'email_conversations#addtag'
  post   'email_conversations/rmtag',            to: 'email_conversations#rmtag'
  post   'email_conversations/rmtag/:emailtag',  to: 'email_conversations#rmtag'

  get 'email_unsubscribes', to: 'email_unsubscribes#create'

  ## G

  get  'galleries',                   :to => 'galleries#index'
  post 'galleries',                   :to => 'galleries#index'
  get  'galleries/view/:slug', :to => 'galleries#show'
  post 'galleries/view/:slug', :to => 'galleries#show'

  # H
  # I
  post 'invoices/search', :to => 'invoices#search'

  # L
  get 'leads',       to: 'leads#index'
  get 'leadsets',    to: 'leadsets#index'
  delete 'leadsets', to: 'leadsets#destroy'

  get 'lead_actions', to: 'lead_actions#create', as: :lead_actions
  get 'locations/show/:slug', to: 'locations#show'
  resources :locations

  ## M

  get 'maps', to: 'maps#index'
  get 'maps/view/:slug', to: 'maps#show'
  get 'markers/view/:slug', to: 'maps#show_marker'
  match  "/my/account", to: "users#account", via: [ :get, :post ]
  namespace :my do
    get  'galleries', to: 'galleries#index'
    get  'newsitems', to: 'newsitems#index'
    get  'videos',    to: 'videos#index'
    post 'videos',    to: 'videos#index'
  end

  # N
  delete 'newsitems/:id', to: 'newsitems#destroy'

  ## O

  get '/obf/:id', to: 'obfuscated_redirects#show', as: :obf

  # resources :option_price_items
  get 'option_price_items/view-by/symbol/:symbol', to: 'option_price_items#view_by_symbol', :constraints => { :symbol => /[^\/]+/ } ## the symbol is detailed eg 'GME_011924P30'
  get 'option_price_items/index1', to: 'option_price_items#index', defaults: { kind: 'kind-1' }
  get 'option_price_items/view/:symbol/from/:begin_at/to/:end_at', to: 'option_price_items#view'


  ## P

  post 'do_purchase', to: 'gameui#do_purchase' # @TODO: rename to just purchase, or destroy endpoint
  post 'payments', :to => 'payments#create'
  post 'payments/unlock', to: 'payments#unlock' # do_purchase
  post 'payments/stripe_confirm', to: 'payments#stripe_confirm' # @TODO: test-drive herehere

  get 'photos/view/:id', to: 'photos#show'
  get 'profiles/view/:username', :to => 'user_profiles#show'

  get 'products/:id', to: 'products#show'

  ## S

  post 'stars/buy', to: 'gameui#buy_stars'


  get 'test',      to: 'application#test'
  get 'exception', to: 'application#exception'

  post  'users/fb_sign_in',      to: 'users#fb_sign_in'
  get   'users/me',              to: 'users#account', as: :users_dashboard
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
