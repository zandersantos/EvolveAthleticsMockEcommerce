require "csv"
require "uri"
require "open-uri"
require "faker"

Product.destroy_all
Category.destroy_all
AdminUser.destroy_all
Page.destroy_all

ActiveRecord::Base.connection.execute("UPDATE sqlite_sequence SET seq = 0 WHERE name = 'categories';")
ActiveRecord::Base.connection.execute("UPDATE sqlite_sequence SET seq = 0 WHERE name = 'products';")

# About and Contact Pages Section
Page.create(
  title: "About EvolveAthletics",
  content:"EvolveAthletics is a MOCK e-Commerce Athletics store. This Project will be used for the E-Commerce Project in the Fullstack Web Development Course in the Business Information Technology program at Red River College.",
  permalink: "about"
)

Page.create(
  title: "Contact Us",
  content:"Email me at zsantos@rrc.ca if you have any questions or inquiries",
  permalink: "contact"
)

# Image Creation
image_client = Pexels::Client.new
product_image = Pexels::Client.new
response = image_client.photos.search('workout', page: 1, per_page: 100)

# Category Creation
filenamecategory = Rails.root.join "db/equipment_categories.csv"
puts "Reading in the file from here #{filenamecategory}"

csv_datacategory = File.read(filenamecategory)
categories = CSV.parse(csv_datacategory, headers: true, encoding: 'utf-8')

categories.each do |category|
  category_record = Category.create(name: category["name"], description: category["description"])

  if category_record.valid?
    puts "#{category["name"]} Created"
  else
    puts "Unable to create the category name #{category["name"]}"
    puts "Errors: #{category_record.errors.full_messages.join(", ")}"
  end
end

puts "Created #{categories.count} Categories"

Category.all.each_with_index do |category, index|
  downloaded_image = URI.parse(response.photos[index].src["tiny"]).open

  category.image.attach(
    io: downloaded_image,
    filename: "#{category.name}.jpg"
  )
end

# Product Creation from CSV
filenameproduct = Rails.root.join "db/fitness_equipment.csv"
puts "Reading in the file from here #{filenameproduct}"

csv_data = File.read(filenameproduct)
products = CSV.parse(csv_data, headers: true, encoding: 'utf-8')

products.each do |product|
  product_record = Product.create(
    name: product["name"],
    description: product["description"],
    price: product["price"],
    stockquantity: product["stockquantity"],
    category_id: product["category_id"]
  )

  pexel_response = image_client.photos.search(product_record.name)
  downloaded_image = URI.parse(pexel_response.photos[0].src["medium"]).open

  product_record.image.attach(io: downloaded_image, filename: "m-#{product_record.name}.jpg")

  if product_record.valid?
    puts "#{product["name"]} Created"
  else
    puts "Unable to create the product name #{product["name"]}"
    puts "Errors: #{product_record.errors.full_messages.join(", ")}"
  end
end

# Auto-generate 100 Random Products
100.times do
  product_name = Faker::Commerce.product_name
  pexel_response = image_client.photos.search(product_name)
  photo = pexel_response.photos[0]
  next unless photo

  downloaded_image = URI.parse(photo.src["medium"]).open

  product_record = Product.create(
    name: product_name,
    description: Faker::Lorem.sentence(word_count: 12),
    price: Faker::Commerce.price(range: 10.0..150.0),
    stockquantity: rand(5..50),
    category_id: rand(1..4)
  )

  product_record.image.attach(
    io: downloaded_image,
    filename: "auto-#{product_name.parameterize}.jpg"
  )

  if product_record.valid?
    puts "#{product_record.name} (auto-generated) created!"
  else
    puts "Failed to create: #{product_record.name}"
    puts "Errors: #{product_record.errors.full_messages.join(', ')}"
  end
end

puts "Created #{Product.count} Products"

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?