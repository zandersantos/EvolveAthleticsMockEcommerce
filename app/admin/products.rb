ActiveAdmin.register Product do

  permit_params :name, :description, :price, :stockquantity, :category_id

end
