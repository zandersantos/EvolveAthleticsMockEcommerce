require "csv"

Product.delete_all
Category.delete_all
ActiveRecord::Base.connection.execute("UPDATE sqlite_sequence SET seq = 0 WHERE name = 'categories';")
ActiveRecord::Base.connection.execute("UPDATE sqlite_sequence SET seq = 0 WHERE name = 'products';")
#Category CREATION

filenamecategory = Rails.root.join "db/equipment_categories.csv"
puts "Reading in the file from here #{filenamecategory}"

csv_datacategory = File.read(filenamecategory)
categories = CSV.parse(csv_datacategory, headers: true, encoding: 'utf-8')

categories.each do |category|

  # Create category records
  category_record = Category.create(name: category["name"], description: category["description"])

  if category_record.valid?
    puts "#{category["name"]} Created"
  else
    puts "Unable to create the category name #{category["name"]}"
    puts "Errors: #{category_record.errors.full_messages.join(", ")}"
  end
end

puts "Created #{categories.count} Categories"

#Product CREATION

filenameproduct = Rails.root.join "db/equipment.csv"
puts "Reading in the file from here #{filenameproduct}"

csv_data = File.read(filenameproduct)
products = CSV.parse(csv_data, headers: true, encoding: 'utf-8')

products.each do |product|

  # Create product records
  product_record = Product.create(name: product["name"], description: product["description"], price: product["price"], stockquantity: product["stockquantity"], category_id: product["category_id"])

  if product_record.valid?
    puts "#{product["name"]} Created"
  else
    puts "Unable to create the product name #{product["name"]}"
    puts "Errors: #{product_record.errors.full_messages.join(", ")}"
  end
end

puts "Created #{Product.count} Products"
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?