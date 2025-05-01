class OrderDetail < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: {only_integer: true}
  validates :price_at_purchase, :total, numericality: true
  validates :quantity, :price_at_purchase, :total, presence: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "order_id", "price_at_purchase", "product_id", "quantity", "updated_at"]
  end

end
