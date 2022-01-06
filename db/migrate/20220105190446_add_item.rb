class AddItem < ActiveRecord::Migration[6.1]
  def change
    create_table :items, id: :uuid do |t|
      t.string :title
      t.string :description
      t.integer :quantity
      t.uuid :collection_id

      t.timestamps
    end
    add_index :items, :collection_id
  end
end
