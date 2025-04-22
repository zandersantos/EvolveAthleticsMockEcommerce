class SearchController < ApplicationController
  def search_all
    @query = params[:query]

    @products = Product.where("name LIKE ?", "%#{query}%")
  end
end
