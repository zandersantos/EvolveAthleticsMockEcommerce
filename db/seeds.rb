require "csv"
require "uri"
require "open-uri"
require "faker"

Product.destroy_all
Category.destroy_all
AdminUser.destroy_all
Page.destroy_all
Province.destroy_all

ActiveRecord::Base.connection.execute("ALTER SEQUENCE categories_id_seq RESTART WITH 1;")
ActiveRecord::Base.connection.execute("ALTER SEQUENCE products_id_seq RESTART WITH 1;")

# ActiveRecord::Base.connection.execute("UPDATE sqlite_sequence SET seq = 0 WHERE name = 'categories';")
# ActiveRecord::Base.connection.execute("UPDATE sqlite_sequence SET seq = 0 WHERE name = 'products';")

# About and Contact Pages Section
Page.create(
  title:     "About EvolveAthletics",
  content:   "EvolveAthletics is a MOCK e-Commerce Athletics store. This Project will be used for the E-Commerce Project in the Fullstack Web Development Course in the Business Information Technology program at Red River College.",
  permalink: "about"
)

Page.create(
  title:     "Contact Us",
  content:   "Email me at zsantos@rrc.ca if you have any questions or inquiries",
  permalink: "contact"
)

# Image Creation
image_client = Pexels::Client.new
Pexels::Client.new
response = image_client.photos.search("workout", page: 1, per_page: 100)

# Category Creation
filenamecategory = Rails.root.join "db/equipment_categories.csv"
Rails.logger.debug { "Reading in the file from here #{filenamecategory}" }

csv_datacategory = File.read(filenamecategory)
categories = CSV.parse(csv_datacategory, headers: true, encoding: "utf-8")

categories.each do |category|
  category_record = Category.create(name: category["name"], description: category["description"])

  if category_record.valid?
    Rails.logger.debug { "#{category['name']} Created" }
  else
    Rails.logger.debug { "Unable to create the category name #{category['name']}" }
    Rails.logger.debug { "Errors: #{category_record.errors.full_messages.join(', ')}" }
  end
end

Rails.logger.debug { "Created #{categories.count} Categories" }

Category.all.each_with_index do |category, index|
  downloaded_image = URI.parse(response.photos[index].src["tiny"]).open

  category.image.attach(
    io:       downloaded_image,
    filename: "#{category.name}.jpg"
  )
end

# Product Creation from CSV
filenameproduct = Rails.root.join "db/fitness_equipment.csv"
Rails.logger.debug { "Reading in the file from here #{filenameproduct}" }

csv_data = File.read(filenameproduct)
products = CSV.parse(csv_data, headers: true, encoding: "utf-8")

products.each do |product|
  product_record = Product.create(
    name:          product["name"],
    description:   product["description"],
    price:         product["price"],
    stockquantity: product["stockquantity"],
    category_id:   product["category_id"]
  )

  pexel_response = image_client.photos.search(product_record.name)
  downloaded_image = URI.parse(pexel_response.photos[0].src["medium"]).open

  product_record.image.attach(io: downloaded_image, filename: "m-#{product_record.name}.jpg")

  if product_record.valid?
    Rails.logger.debug { "#{product['name']} Created" }
  else
    Rails.logger.debug { "Unable to create the product name #{product['name']}" }
    Rails.logger.debug { "Errors: #{product_record.errors.full_messages.join(', ')}" }
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
    name:          product_name,
    description:   Faker::Lorem.sentence(word_count: 12),
    price:         Faker::Commerce.price(range: 10.0..150.0),
    stockquantity: rand(5..50),
    category_id:   rand(1..4)
  )

  product_record.image.attach(
    io:       downloaded_image,
    filename: "auto-#{product_name.parameterize}.jpg"
  )

  if product_record.valid?
    Rails.logger.debug { "#{product_record.name} (auto-generated) created!" }
  else
    Rails.logger.debug { "Failed to create: #{product_record.name}" }
    Rails.logger.debug { "Errors: #{product_record.errors.full_messages.join(', ')}" }
  end
end

Rails.logger.debug { "Created #{Product.count} Products" }

Province.create([
                  { name: "Alberta", gst: 0.05, pst: 0, hst: 0 },
                  { name: "British Columbia", gst: 0.05, pst: 0.07, hst: 0 },
                  { name: "Manitoba", gst: 0.05, pst: 0.07, hst: 0 },
                  { name: "New Brunswick", gst: 0, pst: 0, hst: 0.15 },
                  { name: "Newfoundland and Labrador", gst: 0, pst: 0, hst: 0.15 },
                  { name: "Nova Scotia", gst: 0, pst: 0, hst: 0.15 },
                  { name: "Ontario", gst: 0, pst: 0, hst: 0.13 },
                  { name: "Prince Edward Island", gst: 0, pst: 0, hst: 0.15 },
                  { name: "Quebec", gst: 0.05, pst: 0.09975, hst: 0 },
                  { name: "Saskatchewan", gst: 0.05, pst: 0.06, hst: 0 },
                  { name: "Yukon", gst: 0.05, pst: 0, hst: 0 },
                  { name: "Northwest Territories", gst: 0.05, pst: 0, hst: 0 },
                  { name: "Nunavut", gst: 0.05, pst: 0, hst: 0 }
                ])

if Rails.env.development?
  AdminUser.create!(email: "admin@example.com", password: "password",
                    password_confirmation: "password")
end
