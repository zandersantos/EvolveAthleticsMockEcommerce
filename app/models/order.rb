class Order < ApplicationRecord
  belongs_to :customer

  validates :total, numericality: true
end
