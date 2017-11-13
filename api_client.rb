require 'net/http'
require 'json'

SERVER = 'http://localhost:3000'

def http_request_json(http_method, uri, body = nil)
  # Checking HTTP method to execute
  http_method.upcase!
  case http_method
  when 'PUT'
    req = Net::HTTP::Put.new(uri)
  when 'GET'
    req = Net::HTTP::Get.new(uri)
  when 'POST'
    req = Net::HTTP::Post.new(uri)
  when 'DELETE'
    req = Net::HTTP::Delete.new(uri)
  end
  # Generating request
  req['Accept'] = 'application/json'
  req['Content-Type'] = 'application/json'
  req.body = JSON.generate(body) if body
  # Generating response back to caller
  res = Net::HTTP.start(uri.hostname, uri.port) do |http|
    http.request(req)
  end 
end 

def get_product_list
  uri = URI "#{SERVER}/products"

  res = http_request_json('get', uri)
  json_data = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
end

def get_product(product_id)
  uri = URI "#{SERVER}/products/#{product_id}"

  res = http_request_json('get', uri)
  json_data = JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
end

def update_product(product_id, product)
  uri = URI "#{SERVER}/products/#{product_id}"

  res = http_request_json('put', uri, product)
  (res.code == '200')
end

def create_product(product)
  uri = URI "#{SERVER}/products"

  res = http_request_json('post', uri, product)
  
  if res.is_a?(Net::HTTPSuccess)
    @new_product_id = JSON.parse(res.body)['id']
  end
end

def delete_product(product_id)
  uri = URI "#{SERVER}/products/#{product_id}"

  res = http_request_json('delete', uri)
  (res.code == '204')
end

# Running client
puts "\r\n--- Getting product list ---"
puts get_product_list
puts "\r\n--- Getting product with id:11 ---"
puts get_product(11)
puts "\r\n--- Creating new product ---"
puts create_product({title: "New book just for tests", 
              description: "This is a new book, used for test purposes only", 
              price: 45.0, 
              image_url: "rails.png"})
puts "\r\n--- Updating product ---"
puts update_product(11,{title: "Rails, Angular, Postgres, and Bootstrap", price: 45.0})
puts "\r\n--- Deleting created product id:#{@new_product_id} ---"
puts delete_product(@new_product_id)