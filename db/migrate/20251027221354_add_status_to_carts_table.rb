class AddStatusToCartsTable < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :status, :integer, null: false, default: 0
  end
end
