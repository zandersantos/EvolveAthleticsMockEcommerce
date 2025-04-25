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
    @customer = if params[:customer_id].present?
                  Customer.find_by(id: params[:customer_id])
                else
                  Customer.create(first_name: "Guest", last_name: "User", email_address: "guest@example.com")
                end


    @order = Order.new(customer_id: @customer.id)
    @cart_items = cart

    subtotal = @cart_items.sum do |item|
      item[:quantity] * item[:product].price
    end

    @taxes = calculate_taxes(subtotal, @customer.province)
    @total_price = subtotal + @taxes[:total_tax]

    render :invoice
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
    cart_items = cart

    line_items = cart_items.map do |item|
      {
        price_data: {
          currency: "cad",
          product_data: {
            name: item[:product].name,
            description: item[:product].description
          },
          unit_amount: (item[:product].price * 100).to_i
        },
        quantity: item[:quantity]
      }
    end

    session = Stripe::Checkout::Session.create(
      payment_method_types: ["card"],
      success_url: checkout_success_url,
      cancel_url: checkout_cancel_url,
      mode: "payment",
      line_items: line_items
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

  def submit_invoice
    @order = Order.new(order_params)
    if @order.save
      cart.each do |item|
        OrderDetail.create(
          order: @order,
          product: item[:product],
          quantity: item[:quantity],
          price: item[:product].price
        )
      end

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
