
Rails.application.routes.draw do

  mount Ishapi::Engine => "/ishapi"

  root :to => 'application#home'

  devise_for :users, only: []
  # devise_for :users, :controllers => { # :skip => [ :registrations ],
  #   confirmations: 'users/confirmations',
  #   passwords: 'users/passwords',
  #   registrations: 'users/registrations',
  #   sessions: 'users/sessions',
  #   unlocks: 'users/unlocks',
  # }

end

