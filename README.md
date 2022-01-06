# Basic Inventory CRUD Application
## Installation and Setup
### Dependencies: 
1. Ruby 3.0.1
2. Rails 6.1.4
3. 'pg' gem >= 1.1 (and working installation of Postgresql)
4. Check Gemfile for more information
### Setup
1. To clone the project and switch into it, type: ```git clone https://github.com/jessetuglu/InventorySystem.git and cd InventorySystem```
2. Now run ```bundle install``` to get the dependencies
3. Run ```bin/rails db:setup && bin/rails db:migrate``` to initialize the database
4. Finally, run ```bin/rails s``` to start the server at ```http://localhost:3000```
## Routes
### Inventory Items
- DELETE "/items", deletes all available inventory
- GET "/items", gets all available inventory
- GET "/items/{id}", gets the item associated with {id} (or returns error)
- POST "/items/new", creates a new item, takes in 3 parameters:
  - title: string/required
  - description: string/optional
  - quantity: integer/required, must be ≥ 0
- DELETE "/items/{id}", deletes the item associated with {id} (or returns error)
- PUT "/items/{id}", updates the item associated with {id} (or returns error)
### Inventory Collections
- DELETE "/collections", deletes all available collections
- GET "/collections", gets all available collections
- GET "/collections/{id}", gets the collection associated with {id} (or returns error)
- PUT "/collections/{id}/add_items", adds items to the collection associated with {id}, takes 1 body param:
  - items, array of {id: "..."} objects
- PUT "/collections/{id}/delete_items", deletes items to the collection associated with {id}, takes 1 body param:
    - items, array of {id: "..."} objects
    - Must contain valid items, otherwise will throw error
- POST "/collections/new", creates new collection:
  - name: string/required
- DELETE "/collections/{id}", deletes collection with {id}
- PUT "/collections/{id}", updates collection with {id}

## Testing
- There is a tests file with some very basic tests located at the root of the project
- To run the tests, make sure you are in the root dir and run ```ruby tests.rb```; Errors will be thrown if tests fail. 
