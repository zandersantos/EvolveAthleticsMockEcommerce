class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :initialize_session
  helper_method :cart

  private

  def initialize_session
    session[:cart] ||= []
  end

  def cart
    Product.find(session[:cart])
  end

  def search
    @query = params[:query]
    @results = Page.where("title LIKE ? OR content LIKE ?", "%#{@query}%", "%#{@query}%")
  end
end
