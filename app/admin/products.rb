ActiveAdmin.register Product do

  permit_params :name, :description, :price, :stockquantity, :category_id

  remove_filter :image_attachment, :image_blob

end
