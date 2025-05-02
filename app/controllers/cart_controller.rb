class CartController < ApplicationController
  #Set the cart before the create and destroy actions
  before_action :get_product, only: [:create, :destroy]

  #to_i is used to convert from parameters string to int
  def create
    #Get the product id
    product_id = params[:id].to_i
    #Get the product quantity
    quantity = params[:quantity].to_i

    #Find the existing item in the cart with the same product id
    existing_item = session[:cart].find do |item|
      item_id = item["id"]
      item_id == product_id
    end

    #If the Item is already in the Cart update the Product Quantity and display a message to the User
    if existing_item
      existing_item["quantity"] += quantity
      flash[:notice] = "#{quantity}x #{@product.name} were added to your cart! Total quantity: #{existing_item['quantity']}."
    else
      #If the Item is not in the Cart, add it and display a message to the User
      session[:cart] += [{ "id" => product_id, "quantity" => quantity }]
      flash[:notice] = "#{quantity}x #{@product.name} were added to the cart!"
    end
    redirect_to root_path
  end

  def destroy
    #Get the product
    product_id = params[:id].to_i
    #If the product Id matches, remove the product from the current cart session
    session[:cart].delete_if do |item|
      item_id = item["id"]
      item_id == product_id
    end
    #Display a message to the user that the item wasremoved
    flash[:notice] = "#{@product.name} was removed from the cart!"
    redirect_to root_path
  end

  #Cart Quantity Update Logic Section
  def update_quantity
    #Get the Product
    product = Product.find(params[:id])
    #Get the current quantity
    new_quantity = params[:quantity].to_i

    #Validate that the quantity is more than 0
    if new_quantity > 0
      #Initialize the cart session if it was not created already
      session[:cart] ||= []
      #Find the item with the matching product item
      item = session[:cart].find do |i|
        i["id"] == product.id
      end
      #If Item exists, update the quantity
      if item
        item["quantity"] = new_quantity
      end
      #Display a message telling the user the quantity was updated
      flash[:notice] = "#{product.name} quantity updated."
    else
      #Display a message telling the user that they need a quantity of at least 1
      flash[:alert] = "Quantity must be at least 1."
    end
    redirect_to root_path
  end

  def checkout
  end

  private

  #Cart Get Product Update Logic Section
  def get_product
    product_id = params[:id].to_i
    @product = Product.find(product_id)
  end
end