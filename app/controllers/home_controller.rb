class HomeController < ApplicationController
  def index
    @products = Product.page(params[:page]).per(10)

    @categories = Category.includes(:products).limit(10)
  end
end
