class CustomersController < ApplicationController
  # Set the customer before the edit, update and update_province actions
  before_action :set_customer, only: %i[edit update update_province]
  # Set the customer before the edit and update actions
  before_action :set_provinces, only: %i[edit update]

  def edit
    # @customer and @provinces are set here for editing
  end

  def update
    if @customer.update(customer_params)
      redirect_to profile_path, notice: "Account updated successfully."
    else
      flash.now[:alert] = "There was a problem updating your account."
      render :edit, status: :unprocessable_entity
    end
  end

  # Customer Province Update Logic Section
  def update_province
    # Update the Customers Province and redirect back to the invoice page (Reloads the Page Basically)
    return unless @customer.update(province: params[:province])

    redirect_to order_invoice_path, notice: "Province updated successfully."
  end

  private

  def set_customer
    # Get the Current Customer (devise)
    @customer = current_customer
  end

  def set_provinces
    # Populate the Provinces correctly
    @provinces = ["Alberta", "British Columbia", "Manitoba", "New Brunswick",
                  "Newfoundland and Labrador", "Nova Scotia", "Ontario",
                  "Prince Edward Island", "Quebec", "Saskatchewan",
                  "Yukon", "Northwest Territories", "Nunavut"]
  end

  def customer_params
    params.expect(customer: %i[first_name last_name phone_number email address
                               province])
  end
end
