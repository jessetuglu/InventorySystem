Rails.application.routes.draw do
  delete '/items', to: "item#delete_all"
  get '/items', to: "item#all"

  get '/items/:id', to: "item#get"
  post '/items/new', to: "item#create"
  delete '/items/:id', to: "item#delete"
  put '/items/:id', to: "item#update"

  delete '/collections', to: "collection#delete_all"
  get '/collections', to: "collection#all"

  get '/collections/:id', to: "collection#get"
  put '/collections/:id/add_items', to: "collection#add_items"
  delete '/collections/:id/delete_items', to: "collection#delete_items"

  post '/collections/new', to: "collection#create"
  delete '/collections/:id', to: "collection#delete"
  put '/collections/:id', to: "collection#update"
end
