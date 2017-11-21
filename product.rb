require 'net/http'
require 'json'

class Product 
  class << self
    def find(id)
      found = get_product(id)
      if found
        self.new(found)
      else
        nil
      end
    end

    def all
      product_list = get_product_list
      if product_list
        product_list.map { |product| self.new(product) }
      else
        nil
      end
    end

    def create(product = {})
      creation_result = create_product(product)
      result = self.new(product)
      result.id = creation_result['id']
      result.errors = creation_result unless result.id
      return result
    end

    #protected
    SERVER = 'http://localhost:3000'.freeze

    def http_request_json(http_method, uri, body = nil)
      # Checking HTTP method to execute
      http_method.upcase!
      req = case http_method
      when 'PUT'
        Net::HTTP::Put.new(uri)
      when 'GET'
        Net::HTTP::Get.new(uri)
      when 'POST'
        Net::HTTP::Post.new(uri)
      when 'DELETE'
        Net::HTTP::Delete.new(uri)
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
      if res.is_a?(Net::HTTPSuccess)
        JSON.parse(res.body)
      else
        nil
      end
    end

    def get_product(product_id)
      uri = URI "#{SERVER}/products/#{product_id}"

      res = http_request_json('get', uri)
      if res.is_a?(Net::HTTPSuccess)
        JSON.parse(res.body)
      else 
        nil
      end
    end

    def update_product(product_id, product)
      uri = URI "#{SERVER}/products/#{product_id}"

      res = http_request_json('put', uri, product)
      if res.code == '200'
        true
      else
        JSON.parse(res.body)
      end
    end

    def create_product(product)
      uri = URI "#{SERVER}/products"

      res = http_request_json('post', uri, product)
      
      JSON.parse(res.body)
    end

    def delete_product(product_id)
      uri = URI "#{SERVER}/products/#{product_id}"

      res = http_request_json('delete', uri)
      (res.code == '204')
    end

  end

  attr_accessor :id, :title, :description, :image_url, :price, :errors

  def initialize(product = {})
    product.keys.each { |key| product[key.to_sym] = product[key] unless key.is_a?(Symbol) }
    @id = product[:id].to_i if product[:id]
    @title = product[:title].to_s
    @description = product[:description].to_s
    @image_url = product[:image_url].to_s
    @price = product[:price].to_f if product[:price]
  end

  def update(update_params)
    update_result = Product.update_product(self.id, update_params)
    if update_result == true
      true
    else
      @errors = update_result
      false
    end
  end

  def save
    product_params = {}
    self.instance_variables.each {|var| product_params[var.to_s[1..-1].to_sym] = self.instance_variable_get(var)}
    if self.id
      self.update(product_params)
    else
      result = Product.create_product(product_params)
      if result['id']
        self.id = result['id']
        return true
      else
        self.errors = result
        return false
      end
    end
  end

  def delete
    Product.delete_product(self.id)
  end

end
