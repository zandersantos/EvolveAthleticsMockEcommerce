class Product < ApplicationRecord
  belongs_to :category
  has_many :order_details
  has_one_attached :image

  validates :name, uniqueness: true
  validates :name, :description, presence: true
  validates :stockquantity, numericality: {only_integer: true}
  validates :price, numericality: true

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "description", "id", "id_value", "name", "price", "stockquantity", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["category"]
  end
end
