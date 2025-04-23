class AddTotalToOrderDetails < ActiveRecord::Migration[8.0]
  def change
    add_column :order_details, :total, :decimal
  end
end
