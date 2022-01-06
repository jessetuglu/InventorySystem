Rails.application.routes.draw do
  delete '/items', to: "item#delete_all"
  get '/items', to: "item#all"
  get '/item', to: "item#get"
  post '/items/new', to: "item#create"
  delete '/items/delete', to: "item#delete"
  put '/items/update', to: "item#update"

  delete '/collections', to: "collection#delete_all"
  get '/collections', to: "collection#all"
  get '/collection', to: "collection#get"
  put '/collections/add_items', to: "collection#add_items"
  delete '/collections/delete_items', to: "collection#delete_items"
  post '/collections/new', to: "collection#create"
  delete '/collections/delete', to: "collection#delete"
  put '/collections/update', to: "collection#update"
end
