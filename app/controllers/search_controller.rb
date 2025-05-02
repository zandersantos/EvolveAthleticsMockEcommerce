class SearchController < ApplicationController

  #Category Dropdown search section
  #This section lets the user do:
  #1) A normal search with a search bar
  #2) Search by a category dropdown
  #3) Search for a prodcut within a category (combines queries)
  def search_all
    @query = params[:query]
    @category_id = params[:category_id]

    #3
    #If both the search query and the category dropdown is present
    if @query.present? && @category_id.present?
      @products = Product.where(category_id: @category_id).where("name ILIKE ?", "%#{@query}%")
      @categories = Category.where(id: @category_id)
    #1
    #If only the search query is present
    elsif @query.present?
      @products = Product.where("name ILIKE ?", "%#{@query}%")
      @categories = Category.where("name ILIKE ?", "%#{@query}%")
    #2)
    #If only the category dropdown is present
    elsif @category_id.present?
      @products = Product.where(category_id: @category_id)
      @categories = Category.where(id: @category_id)
    #If the user doesnt search and doesnt choose a category, display everything to the user
    else
      @products = Product.all
      @categories = Category.all
    end
  end
end
