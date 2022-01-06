class RemoveIndexFromItems < ActiveRecord::Migration[6.1]
  def change
    remove_index :items, :collection_id
  end
end
