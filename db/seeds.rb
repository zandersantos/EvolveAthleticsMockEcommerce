require "csv"

#Product CREATION

Product.delete_all


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

puts "Created #{{Product}.count} Names"
