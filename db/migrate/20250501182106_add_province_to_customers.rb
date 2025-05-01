class AddProvinceToCustomers < ActiveRecord::Migration[8.0]
  def change
    add_reference :customers, :province, foreign_key: true, null: true
  end
end
