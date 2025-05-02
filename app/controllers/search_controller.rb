class SearchController < ApplicationController
  def search_all
    @query = params[:query]

    # If the user searches and it matches a category name. Instead display the category search view.
    # Display all products that is associated with that query
    matching_category = Category.where("LOWER(name) = ?", @query.downcase).first

    if matching_category
      @products = Product.where(category_id: matching_category.id)
      @categories = Category.where(id: matching_category.id)
      @category_id = matching_category.id
    else
      # Search for Products and/or Categories
      @products = Product.where("name LIKE ?", "%#{@query}%")
      @categories = Category.where("name LIKE ?", "%#{@query}%")
    end
  end

  # Category Dropdown search section
  def search_by_category
    @category_id = params[:category_id]

    @products = Product.where(category_id: @category_id)

    @categories = Category.where(id: @category_id)

    render :search_all
  end
end
