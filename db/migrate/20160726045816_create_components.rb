class CreateComponents < ActiveRecord::Migration[5.0]
  def change
    create_table :components do |t|
      t.string :name
      t.text :description
      t.integer :category_id
    end
  end
end
