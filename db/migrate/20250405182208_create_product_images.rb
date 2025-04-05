class CreateProductImages < ActiveRecord::Migration[8.0]
  def change
    create_table :product_images do |t|
      t.string :ImageUrl
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
