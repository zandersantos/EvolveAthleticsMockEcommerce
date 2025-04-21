class Page < ApplicationRecord
  validates :title, :content, :permalink, presence: true
  validates :permalink, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    ["content", "created_at", "id", "id_value", "permalink", "title", "updated_at"]
  end
end
