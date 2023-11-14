# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb
require 'open-uri'

# Product.create(name: 'Example Product', description: 'This is an example product.', price: 9.99, inventory_count: 100)

30.times do
  product = Product.new(
    name: Faker::Commerce.product_name,
    price: Faker::Commerce.price(range: 0.99..99.99),
    description: Faker::Lorem.sentence(word_count: 20)
  )

  # Attach an image from the fixtures files
  file_path = Rails.root.join('spec', 'fixtures', 'files', 'image.png')
  product.images.attach(io: File.open(file_path), filename: 'image.png')

  product.save!
end

puts "Created #{Product.count} products."
