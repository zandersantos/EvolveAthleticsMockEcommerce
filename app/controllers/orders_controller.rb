class OrdersController < ApplicationController
  before_action :set_order, only: %i[ show edit update destroy ]

  # GET /orders or /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1 or /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    def new
      @order = Order.new # Ensure @order is initialized
      @cart_items = cart # Retrieve items from the session cart
      @total_price = @cart_items.sum { |item| item[:quantity] * item[:product].price } # Calculate total price
    end
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders or /orders.json
  def create

    product = Product.find(params[:product_id])

    if product.nil?
      redirect_to root_path
      return
    end
    product_cents = (product.price * 100).to_i
    session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      success_url: checkout_success_url,
      cancel_url: checkout_cancel_url,
      mode: "payment",
      line_items: [
        price_data: {
          currency: "cad",
          product_data: {
            name: product.name,
            description: product.description,
          },
          unit_amount: product_cents
        },
        quantity: 1
      ]
    )
    redirect_to session.url, allow_other_host: true
  end

  # PATCH/PUT /orders/1 or /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to @order, notice: "Order was successfully updated." }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1 or /orders/1.json
  def destroy
    @order.destroy!

    respond_to do |format|
      format.html { redirect_to orders_path, status: :see_other, notice: "Order was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  def success
    # We go here if the payment succeeded!
  end

  def cancel
    # Something went wrong!
  end




end
