class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :initialize_cart
  helper_method :cart

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
end
