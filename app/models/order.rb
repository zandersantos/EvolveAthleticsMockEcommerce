class Order < ApplicationRecord
  belongs_to :customer

  validates :total, numericality: true

  has_many :order_details
  has_many :products, through: :order_details
end
