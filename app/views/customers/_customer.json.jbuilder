json.extract! customer, :id, :first_name, :last_name, :email_address, :phone_number, :created_at,
              :updated_at
json.url customer_url(customer, format: :json)
