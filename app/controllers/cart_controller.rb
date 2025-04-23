class CartController < ApplicationController
  before_action :get_product, only: [:create, :destroy]


  def create
    product_id = params[:id].to_i
    quantity = params[:quantity].to_i
    unless session[:cart].any? { |item| item["id"] == product_id }
      session[:cart] << { "id" => product_id, "quantity" => quantity }
      flash[:notice] = "#{quantity}x #{@product.name} were added to the cart!"
    end
    redirect_to root_path
  end

  def destroy
    product_id = params[:id].to_i
    session[:cart].reject! { |item| item["id"] == product_id }
    flash[:notice] = "#{@product.name} was removed from the cart!"
    redirect_to root_path
  end

  private

  def get_product
    product_id = params[:id].to_i
    @product = Product.find(product_id)
  end
end
