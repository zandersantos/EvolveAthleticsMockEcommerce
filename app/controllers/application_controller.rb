class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :initialize_cart
  before_action :load_categories

  helper_method :cart
  before_action :configure_permitted_parameters, if: :devise_controller?
  def all_categories
    @all_categories = Category.all
  end


  protected
  def configure_permitted_parameters
    added_attrs = [:first_name, :last_name, :address, :province, :phone_number, :email, :password, :password_confirmation, :current_password]
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end
  private

  def initialize_cart
    session[:cart] ||= []
  end

  def cart
    session[:cart].map do |item|
      { product: Product.find(item["id"]), quantity: item["quantity"] }
    end
  end

  def search
    @query = params[:query]
    @results = Page.where("title LIKE ? OR content LIKE ?", "%#{@query}%", "%#{@query}%")

  end
  def load_categories
    @categories = Category.all
    @all_categories = all_categories()
  end
end
