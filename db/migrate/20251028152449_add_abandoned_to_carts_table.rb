class AddAbandonedToCartsTable < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :abandoned, :boolean, null: false, default: false
    add_column :carts, :last_interaction_at, :datetime, null: false, precision: 6, default: -> { 'CURRENT_TIMESTAMP' }
  end
end
