class HomeController < ApplicationController
  def index
    @product = Product.order("name DESC").limit(10)

    @categories = Category.includes(:products).limit(10)
  end
end
