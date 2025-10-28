class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.references :cart, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :quantity, precision: 17, scale: 2

      t.index [:cart_id, :product_id], unique: true, name: "index_cart_items_on_cart_and_product"

      t.timestamps
    end
  end
end
