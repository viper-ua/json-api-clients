require 'net/http'
require 'json'

def get_product_list
  uri = URI "http://localhost:3000/products"

  req = Net::HTTP::Get.new(uri)
  req['Accept'] = 'application/json'

  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
  json_data = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
  puts "Trying to get product list..."
  puts "Response: #{res.code}:#{res.message}"

  if json_data
    puts "JSON returned #{json_data.length} records on top level: "
    json_data.each do |product|
      puts "id:#{product['id']} -> #{product['title']} ($#{product['price']})"
    end
  end
  puts
end

def get_product(product_id)
  uri = URI "http://localhost:3000/products/#{product_id}"

  req = Net::HTTP::Get.new(uri)
  req['Accept'] = 'application/json'

  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
  json_data = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
  puts "Trying to get product with id:#{product_id}"
  puts "Response: #{res.code}:#{res.message}"

  if json_data
    puts "JSON returned #{json_data.length} records on top level: "
    puts "id:#{json_data['id']} -> #{json_data['title']} ($#{json_data['price']})"
  end
  puts
end

def update_product(product_id, product)
  uri = URI "http://localhost:3000/products/#{product_id}.json"

  req = Net::HTTP::Put.new(uri)
  req['Accept'] = 'application/json'
  req['Content-Type'] = 'application/json'
  req.body = JSON.generate(product)

  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
  json_data = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
  puts "Updating product id:#{product_id}"
  puts "Response: #{res.code}:#{res.message}"

  if json_data
    puts "JSON returned #{json_data.length} records on top level: "
    puts "id:#{json_data['id']} -> #{json_data['title']} ($#{json_data['price']})"
  end
  puts
end

def create_product(product)
  uri = URI "http://localhost:3000/products.json"

  req = Net::HTTP::Post.new(uri)
  req['Accept'] = 'application/json'
  req['Content-Type'] = 'application/json'
  req.body = JSON.generate(product)

  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
  json_data = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
  puts "Trying to create new test product"
  puts "Response: #{res.code}:#{res.message}"

  if json_data
    puts "JSON returned #{json_data.length} records on top level: "
    puts "id:#{json_data['id']} -> #{json_data['title']} ($#{json_data['price']})"
    @new_product_id = json_data['id']
  end
  puts
end

def delete_product(product_id)
  uri = URI "http://localhost:3000/products/#{product_id}.json"

  req = Net::HTTP::Delete.new(uri)
  req['Accept'] = 'application/json'
  req['Content-Type'] = 'application/json'

  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end
  puts "Trying to delete test product with id:#{product_id}"
  puts "Response: #{res.code}:#{res.message}"
  puts
end

get_product_list
get_product(11)
create_product({"title": "New book just for tests",
              "description": "This is a new book, used for test purposes only",
              "price": 45.0, 
              "image_url": "rails.png"})
update_product(11,{"title": "Rails, Angular, Postgres, and Bootstrap","price": 45.0})
delete_product(@new_product_id)