class OrdersController < ApplicationController
  #Set the order before the show, edit, and destroy
  before_action :set_order, only: %i[ show edit destroy ]
  #Authenticate the Customer is logged in before going to the Invoice
  before_action :authenticate_customer!, only: [:invoice]
  # GET /orders or /orders.json
  def index
    @orders = Order.all
  end

  # GET /orders/1 or /orders/1.json
  def show
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
    order = Order.find(params[:order_id])

    #Stripe Checkout
    line_items = order.order_details.map do |detail|
      {
        price_data: {
          currency: "cad",
          product_data: {
            name: detail.product.name,
            description: detail.product.description
          },
          #Stripe expects amounts in cents
          unit_amount: (detail.price_at_purchase * 100).to_i
        },
        quantity: detail.quantity
      }
    end

    # Create a Stripe Checkout Session
    session = Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      line_items: line_items,
      mode: "payment",
      success_url: "#{checkout_success_url}?session_id={CHECKOUT_SESSION_ID}",
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


  #Order Success Logic Section
  def success
    #Get the Full Order from the Session
    order = Order.find_by(id: session[:last_order_id])

    #Error Handling: If there is no Order Found, go back to the homepage and alert the User
    if order.nil?
      redirect_to root_path, alert: "Order not found."
      return
    end

    #Retrieve the Stripe session
    session_id = params[:session_id]
    stripe_session = Stripe::Checkout::Session.retrieve(session_id)

    #Get the payment ID from the Stripe session
    #payment_intent = Unique Stripe Session String ID
    payment_id = stripe_session.payment_intent

    #Add the payment Id to the Order
    order.update(payment_id: payment_id)

    #Update stockquantity
    order.order_details.each do |detail|
      product = detail.product
      if product
        new_quantity = product.stockquantity - detail.quantity
        product.update(stockquantity: new_quantity)
      end
    end

    #Restart the Session by clearing the cart and session references
    session[:cart] = []
    session[:last_order_id] = nil
  end

  #Order Cancel Logic Section
  def cancel
  end

  #Order Invoice Logic Section
  def invoice
    #Customer is the current logged in customer (devise)
    @customer = current_customer
    #Get the current customers province to use for Taxes
    @province = @customer.province

    #Get all Cart Items
    @cart_items = cart

    #Get the Subtotal of the Cart
    subtotal = @cart_items.sum do |item|
      item_quantity = item[:quantity]
      item_price = item[:product].price
      item_quantity * item_price
    end

    #Use calculate_taxes to get province based taxes
    @taxes = calculate_taxes(subtotal, @province)

    #Calculate the total tax
    @total_price = subtotal + @taxes[:total_tax]

    #Create a new Order
    @order = Order.new
  end

  #Order Invoice Submittion Logic Section
  def submit_invoice
    #Get the Current Customer
    @customer = Customer.find(params[:customer_id])

    #Get whatever is in the cart
    @cart_items = session[:cart] || []

    #If cart = empty, redirect back to the homepage and display and alert to the user
    if @cart_items.empty?
      redirect_to root_path, alert: "Your cart is empty. Please add items before submitting the invoice."
      return
    end

    #Associate the Cart Items with their correct Product
    associated_cart_items = @cart_items.map do |item|
      #Find the Product associated with the Cart Item
      product = Product.find_by(id: item["id"])
      #Create a basic hash to associate the product with quantity
      # Identical to below { :product => product, :quantity => item["quantity"] }
      { product: product, quantity: item["quantity"] }
    end

    #Calculate the cart total
    order_total = associated_cart_items.sum do |item|
      quantity = item[:quantity]
      price = item[:product].price
      quantity * price
    end

    #Create a new Order record
    order = Order.create!(
      total: order_total,
      order_date: Date.today,
      customer_id: @customer.id
    )

    #Create a new OrderDetail record through the order and cart
    associated_cart_items.each do |item|
      OrderDetail.create!(
        quantity: item[:quantity],
        price_at_purchase: item[:product].price,
        order_id: order.id,
        total: item[:quantity] * item[:product].price,
        product_id: item[:product].id
      )
      session[:last_order_id] = order.id
    end

    #Clear the Cart after completed payment
    session[:cart] = []

    #Redirect the user to the Success View
    redirect_to checkout_create_path(order_id: order.id)

  end

  #Order Customer Past Orders Logic Section
  def customer_index
    #Get the Customer
    @customer = Customer.find(params[:id])
    #Get the Orders associated with the Customer
    @orders = @customer.orders.includes(:order_details => :product).order(created_at: :desc)

    #Go through each order and re-calculate the price, taxes and total
    @orders.each do |order|
      total_price = 0
      order.order_details.each do |detail|
        total_price += detail.price_at_purchase * detail.quantity
      end

      #Calculate taxes for each order
      taxes = calculate_taxes(total_price, @customer.province)

      #Store the calculated taxes as instance variables so it can be retrieved in the invoice view
      order.instance_variable_set(:@taxes, taxes)
    end
  end

  private

  def order_params
    params.require(:order).permit(:total, :order_date, order_details_attributes: [:product_id, :quantity, :price_at_purchase, :total])
  end

  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :phone_number, :email, :address, :province)
  end


  #Province Tax Rate Hash
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

  #Calculate the taxes based on the retrieved SubTotal and Customer Province
  def calculate_taxes(subtotal, province)
    #Get the Province's taxes based on the above Hash
    tax_rate = TAX_RATES[province]
    #Calculate the taxes by getting the subtotal and Hash Tax Rate
    gst = subtotal * (tax_rate[:gst])
    pst = subtotal * (tax_rate[:pst])
    hst = subtotal * (tax_rate[:hst])

    {
      #Individual Taxes
      gst: gst,
      pst: pst,
      hst: hst,
      #Total Tax
      total_tax: gst + pst + hst
    }
  end

end
