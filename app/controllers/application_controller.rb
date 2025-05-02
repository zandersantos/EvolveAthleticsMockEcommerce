class ApplicationController < ActionController::Base
  # Make sure to run initialize cart and load categories
  before_action :initialize_cart
  before_action :load_categories
  before_action :configure_permitted_parameters, if: :devise_controller?

  # helper_method: Makes a controller method accessible in the views sections
  helper_method :cart

  # All Categories Logic Section
  def all_categories
    @all_categories = Category.all
  end

  protected

  def configure_permitted_parameters
    added_attrs = %i[first_name last_name address province phone_number email password
                     password_confirmation current_password]
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end

  private

  # Initialize a Cart instantly Logic Section
  def initialize_cart
    session[:cart] ||= []
  end

  # Associate/Map Cart Items Logic Section
  def cart
    session[:cart].map do |item|
      {
        product:  Product.find(item["id"]),
        quantity: item["quantity"]
      }
    end
  end

  # Search Bar Logic Section
  def search
    @query = params[:query]
    @results = Page.where("title LIKE ? OR content LIKE ?", "%#{@query}%", "%#{@query}%")
  end

  # Load All Categories Logic Section
  def load_categories
    @categories = Category.all
    # Used to display all categories
    @all_categories = all_categories
  end
end
