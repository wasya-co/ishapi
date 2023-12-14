Rails.application.routes.draw do
  mount Ishapi::Engine => "/api"
end
