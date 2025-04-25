ActiveAdmin.register Customer do
  permit_params :email_address, :first_name, :last_name, :address, :phone_number, :province

  form do |f|
    f.inputs do
      f.input :email_address
      f.input :first_name
      f.input :last_name
      f.input :address
      f.input :phone_number
    end
    f.actions
  end
end