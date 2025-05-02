class ProductsController < ApplicationController
  # Set the product before the show, edit, update and destroy actions
  before_action :set_product, only: %i[show edit update destroy]
  before_action :track_visit, only: [:show]

  # GET /products or /products.json
  def index
    @products = Product.includes(:category).order(name: :asc, created_at: :asc).page(params[:page]).per(20)
  end

  # GET /products/1 or /products/1.json
  def show
    @product = Product.find(params[:id])
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit; end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html do
        redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed."
      end
      format.json { head :no_content }
    end
  end

  # Tracking Product Sessions Logic Section
  def track_visit
    session[:visit] ||= 0
    session[:visit] += 1

    flash[:notice] = "You've visited #{session[:visit]} products!"
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_product
    @product = Product.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def product_params
    params.expect(product: %i[name description price stockquantity category_id])
  end
end
