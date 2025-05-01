class CustomersController < ApplicationController
  # Callback to set the current customer for relevant actions
  before_action :set_customer, only: %i[edit update update_province]
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

  # Action to update province directly
  def update_province
    if @customer.update(province: params[:province])
      redirect_to order_invoice_path, notice: "Province updated successfully."
    else
      flash[:alert] = "There was an error updating the province."
      redirect_to order_invoice_path, status: :unprocessable_entity
    end
  end

  private

  def set_customer
    # Ensure we load the current customer
    @customer = current_customer # Assumes Devise or similar authentication
  end

  def set_provinces
    # Populate list of provinces for forms
    @provinces = ["Alberta", "British Columbia", "Manitoba", "New Brunswick",
                  "Newfoundland and Labrador", "Nova Scotia", "Ontario",
                  "Prince Edward Island", "Quebec", "Saskatchewan",
                  "Yukon", "Northwest Territories", "Nunavut"]
  end

  def customer_params
    # Strong parameters to allow permitted attributes
    params.require(:customer).permit(:first_name, :last_name, :phone_number, :email, :address, :province)
  end
end
