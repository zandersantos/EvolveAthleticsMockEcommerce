class CartController < ApplicationController
  before_action :get_product, only: [:create, :destroy]


  def create
    product_id = params[:id].to_i
    quantity = params[:quantity].to_i

    existing_item = session[:cart].find { |item| item["id"] == product_id }

    if existing_item
      existing_item["quantity"] += quantity
      flash[:notice] = "#{quantity}x #{@product.name} were added to your cart! Total quantity: #{existing_item['quantity']}."
    else
      session[:cart] << { "id" => product_id, "quantity" => quantity }
      flash[:notice] = "#{quantity}x #{@product.name} were added to the cart!"
    end
    redirect_to root_path
  end

  def destroy
    product_id = params[:id].to_i
    session[:cart].delete_if { |item| item["id"] == product_id }
    flash[:notice] = "#{@product.name} was removed from the cart!"
    redirect_to root_path
  end

  def update_quantity
    product = Product.find(params[:id])
    new_quantity = params[:quantity].to_i

    if new_quantity > 0
      session[:cart] ||= []
      item = session[:cart].find do |i|
        i["id"] == product.id
      end

      if item
        item["quantity"] = new_quantity
      end

      flash[:notice] = "#{product.name} quantity updated."
    else
      flash[:alert] = "Quantity must be at least 1."
    end

    redirect_to root_path
  end

  private

  def get_product
    product_id = params[:id].to_i
    @product = Product.find(product_id)
  end
end
