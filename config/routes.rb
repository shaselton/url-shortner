Rails.application.routes.draw do
  post 'url' => 'url#create'
  get ':url' => 'url#show'
end