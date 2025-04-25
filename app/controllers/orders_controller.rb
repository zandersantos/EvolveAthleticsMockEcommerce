class OrdersController < ApplicationController
  before_action :set_order, only: %i[ show edit update destroy ]

  # GET /orders or /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1 or /orders/1.json
  def show
  end
  def invoice
    @order = Order.new # Initialize a new order instance
    @cart_items = cart # Retrieve cart items
    subtotal = @cart_items.sum { |item| item[:quantity] * item[:product].price }
    @province = params[:province] || "Alberta" # Default province for demonstration
    @taxes = calculate_taxes(subtotal, @province) # Calculate taxes
    @total_price = subtotal + @taxes[:total_tax] # Calculate total price
  end
  # GET /orders/new
  def new
      @order = Order.new # Ensure @order is initialized
      @cart_items = cart # Retrieve items from the session cart
      @total_price = @cart_items.sum { |item| item[:quantity] * item[:product].price } # Calculate total price
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders or /orders.json
  def create
    # Collect the cart items
    cart_items = cart

    # Prepare the line items for Stripe
    line_items = cart_items.map do |item|
      {
        price_data: {
          currency: "cad",
          product_data: {
            name: item[:product].name,
            description: item[:product].description
          },
          unit_amount: (item[:product].price * 100).to_i # Price in cents
        },
        quantity: item[:quantity]
      }
    end

    # Create the Stripe checkout session
    session = Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      success_url: checkout_success_url,
      cancel_url: checkout_cancel_url,
      mode: "payment",
      line_items: line_items
    )

    # Redirect the user to Stripe checkout
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

  def submit_invoice
    @order = Order.new(order_params)
    if @order.save
      # Save the cart items into the OrderDetails table
      cart.each do |item|
        OrderDetail.create(
          order: @order,
          product: item[:product],
          quantity: item[:quantity],
          price: item[:product].price
        )
      end
      # Clear the cart (optional)
      session[:cart] = nil
      redirect_to checkout_create_path(order_id: @order.id), notice: "Your invoice has been submitted successfully!"
    else
      flash[:alert] = "There was an error saving your details. Please try again."
      render :invoice
    end
  end

  private

  def order_params
    params.require(:order).permit(:first_name, :last_name, :phone_number, :email, :address, :province)
  end

  TAX_RATES = {
    "Alberta" => { gst: 0.05, pst: 0, hst: 0 },
    "British Columbia" => { gst: 0.05, pst: 0.07, hst: 0 },
    "Manitoba" => { gst: 0.05, pst: 0.07, hst: 0 },
    "New Brunswick" => { gst: 0, pst: 0, hst: 0.15 },
    "Newfoundland and Labrador" => { gst: 0, pst: 0, hst: 0.15 },
    "Nova Scotia" => { gst: 0, pst: 0, hst: 0.15 },
    "Ontario" => { gst: 0, pst: 0, hst: 0.13 },
    "Prince Edward Island" => { gst: 0, pst: 0, hst: 0.15 },
    "Quebec" => { gst: 0.05, pst: 0.09975, hst: 0 },
    "Saskatchewan" => { gst: 0.05, pst: 0.06, hst: 0 },
    "Yukon" => { gst: 0.05, pst: 0, hst: 0 },
    "Northwest Territories" => { gst: 0.05, pst: 0, hst: 0 },
    "Nunavut" => { gst: 0.05, pst: 0, hst: 0 }
  }

  def calculate_taxes(subtotal, province)
    tax_rate = TAX_RATES[province]
    gst = subtotal * tax_rate[:gst]
    pst = subtotal * tax_rate[:pst]
    hst = subtotal * tax_rate[:hst]
    { gst: gst, pst: pst, hst: hst, total_tax: gst + pst + hst }
  end
end
