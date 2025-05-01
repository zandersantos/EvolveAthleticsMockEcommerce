class OrdersController < ApplicationController
  before_action :set_order, only: %i[ show edit destroy ]
  before_action :authenticate_customer!, only: [:invoice]
  # GET /orders or /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1 or /orders/1.json
  def show
  end
  def invoice
    @customer = current_customer
    @province = @customer.province

    @cart_items = cart

    subtotal = @cart_items.sum { |item| item[:quantity] * item[:product].price }

    @taxes = calculate_taxes(subtotal, @province)

    @total_price = subtotal + @taxes[:total_tax]

    # Initialize an empty order object
    @order = Order.new
  end







  # GET /orders/new
  def new
      @order = Order.new
      @cart_items = cart
      @total_price = @cart_items.sum do |item|
        item[:quantity] * item[:product].price
      end
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders or /orders.json
  def create
    # Fetch the order based on the passed `order_id`
    order = Order.find(params[:order_id])

    # Build line items for Stripe Checkout
    line_items = order.order_details.map do |detail|
      {
        price_data: {
          currency: "cad",
          product_data: {
            name: detail.product.name,
            description: detail.product.description
          },
          unit_amount: (detail.price_at_purchase * 100).to_i # Stripe expects amounts in cents
        },
        quantity: detail.quantity
      }
    end

    # Create a Stripe Checkout Session
    session = Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      line_items: line_items,
      mode: "payment",
      success_url: checkout_success_url,
      cancel_url: checkout_cancel_url
    )

    # Redirect the user to Stripe's checkout page
    redirect_to session.url, allow_other_host: true
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
    @cart = session[:cart] || []

    valid_items = @cart.select do |item|
      Product.exists?(id: item["id"])
    end

    valid_items.each do |item|
      product = Product.find_by(id: item["id"])
      quantity = item["quantity"].to_i

      if product
        product.update(stockquantity: product.stockquantity - quantity)
      end
    end

    session[:cart] = []
  end

  def cancel
  end

  # In your OrdersController
  def submit_invoice
    # Ensure the customer exists
    @customer = Customer.find(params[:customer_id])

    # Ensure cart items are present in session and format it correctly
    @cart_items = session[:cart] || []

    # If cart is empty, redirect back with an alert
    if @cart_items.empty?
      redirect_to root_path, alert: "Your cart is empty. Please add items before submitting the invoice."
      return
    end

    # Format the cart items into the expected format
    formatted_cart_items = @cart_items.map do |item|
      product = Product.find_by(id: item["id"])  # Use find_by to return nil if product is not found
      if product.nil?
        # Log the product id and indicate it's missing
        Rails.logger.debug "Product with ID #{item['id']} not found in the database."
        flash[:alert] = "Product with ID #{item['id']} not found."
        redirect_to root_path and return
      end
      { product: product, quantity: item["quantity"] }
    end

    # Calculate the total from the formatted cart items
    order_total = formatted_cart_items.sum { |item| item[:quantity] * item[:product].price }

    # Create the Order
    order = Order.create!(
      total: order_total,
      order_date: Date.today,
      customer_id: @customer.id
    )

    # Create order details for each cart item
    formatted_cart_items.each do |item|
      # Log the product details to debug the issue
      Rails.logger.debug "Creating OrderDetail with product: #{item[:product].inspect}, quantity: #{item[:quantity]}"

      # Check if the product exists before creating OrderDetail
      if item[:product].nil?
        flash[:alert] = "Invalid product found in your cart."
        redirect_to root_path and return
      end

      OrderDetail.create!(
        quantity: item[:quantity],
        price_at_purchase: item[:product].price,
        order_id: order.id,
        total: item[:quantity] * item[:product].price,
        product_id: item[:product].id  # Explicitly pass the product_id
      )
    end

    # Clear cart after order is placed
    session[:cart] = []

    # Redirect to a success page
    redirect_to checkout_create_path(order_id: order.id)

  end








  private

  def order_params
    params.require(:order).permit(:total, :order_date, order_details_attributes: [:product_id, :quantity, :price_at_purchase, :total])
  end



  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :phone_number, :email, :address, :province)
  end


  #Hash
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
    tax_rate = TAX_RATES[province] || {}
    gst = subtotal * (tax_rate[:gst] || 0)
    pst = subtotal * (tax_rate[:pst] || 0)
    hst = subtotal * (tax_rate[:hst] || 0)

    {
      gst: gst,
      pst: pst,
      hst: hst,
      total_tax: gst + pst + hst
    }
  end

end
