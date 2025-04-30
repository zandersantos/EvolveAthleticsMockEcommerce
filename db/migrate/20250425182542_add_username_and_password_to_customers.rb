class AddUsernameAndPasswordToCustomers < ActiveRecord::Migration[8.0]
  def change
    add_column :customers, :username, :string
    add_column :customers, :password, :string
  end
end
