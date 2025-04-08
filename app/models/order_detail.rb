class OrderDetail < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, numericality: {only_integer: true}
  validates :price_at_purchase, numericality: true
end
