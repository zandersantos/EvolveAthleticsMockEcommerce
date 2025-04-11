class Category < ApplicationRecord
  validates :name, uniqueness: true

  has_many :products

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "description", "id", "id_value", "name", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["products"]
  end
end
