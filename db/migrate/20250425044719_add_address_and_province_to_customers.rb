class AddAddressAndProvinceToCustomers < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :address, :string
    add_column :customers, :province, :string
  end
end
