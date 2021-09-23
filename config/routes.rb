Rails.application.routes.draw do
  root 'home#index'
  get 'results/index'
end
