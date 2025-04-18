class HomeController < ApplicationController
  def index
    @product = Product.order("name ASC").limit(10)

    @categories = Category.includes(:products).limit(10)
  end
end
