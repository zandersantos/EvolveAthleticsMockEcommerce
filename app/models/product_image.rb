class ProductImage < ApplicationRecord
  belongs_to :product

  validates :imageurl, uniqueness: true
end
