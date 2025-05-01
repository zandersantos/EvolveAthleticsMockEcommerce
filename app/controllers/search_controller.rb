class SearchController < ApplicationController
  def search_all
    @query = params[:query]

    # Try to match the query to a category name exactly (case insensitive)
    matching_category = Category.where('LOWER(name) = ?', @query.downcase).first

    if matching_category
      @products = Product.where(category_id: matching_category.id)
      @categories = Category.where(id: matching_category.id)
      @category_id = matching_category.id  # For use in the view title
    else
      # Regular search for products and categories with LIKE
      @products = Product.where("name LIKE ?", "%#{@query}%")
      @categories = Category.where("name LIKE ?", "%#{@query}%")
    end
  end


  def search_by_category
    @category_id = params[:category_id]

    # Filter products based on selected category
    @products = Product.where(category_id: @category_id)

    # Ensure ONLY the selected category shows
    @categories = Category.where(id: @category_id)


    render :search_all
  end




end
