class Product < ApplicationRecord
  belongs_to :category

  validates :name, uniqueness: true
  validates :stockquantity, numericality: {only_integer: true}
  validates :price, numericality: true
end
