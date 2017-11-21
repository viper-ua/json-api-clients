require 'net/http'
require 'json'

class Product 
  # Product class methods
  class << self
    def find(id)
      found = HttpIf.get_product(id)
      self.new(found) if found
    end

    def all
      product_list = HttpIf.get_product_list
      product_list.map { |product| self.new(product) } if product_list 
    end

    def create(product = {})
      creation_result = HttpIf.create_product(product)
      result = self.new(product)
      result.id = creation_result['id']
      result.errors = creation_result unless result.id
      return result
    end
  end

  # Product class instance methods
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
    update_result = HttpIf.update_product(@id, update_params)
    return true if update_result == true
    @errors = update_result
    false
  end

  def save
    product_params = {}
    self.instance_variables.each {|var| product_params[var.to_s[1..-1].to_sym] = self.instance_variable_get(var)}
    return self.update(product_params) if @id
    result = HttpIf.create_product(product_params)
    if result['id']
      @id = result['id']
      true
    else
      @errors = result
      false
    end
  end

  def delete
    HttpIf.delete_product(@id)
  end
end

# Class for HTTP interface
class HttpIf
  class << self
    # class methods for server interaction
    SERVER = 'http://localhost:3000'.freeze

    def http_request_json(http_method, body = nil)
      # Checking HTTP method to execute
      http_method.upcase!
      req = case http_method
      when 'PUT'
        Net::HTTP::Put.new(@uri)
      when 'GET'
        Net::HTTP::Get.new(@uri)
      when 'POST'
        Net::HTTP::Post.new(@uri)
      when 'DELETE'
        Net::HTTP::Delete.new(@uri)
      end
      # Generating request
      req['Accept'] = 'application/json'
      req['Content-Type'] = 'application/json'
      req.body = JSON.generate(body) if body
      # Generating response back to caller
      @res = Net::HTTP.start(@uri.hostname, @uri.port) {|http| http.request(req)} 
    end 

    def get_product_list
      @uri = URI "#{SERVER}/products"
      http_request_json('get')
      return unless @res.is_a?(Net::HTTPSuccess)
      JSON.parse(@res.body)
    end

    def get_product(product_id)
      @uri = URI "#{SERVER}/products/#{product_id}"
      http_request_json('get')
      return unless @res.is_a?(Net::HTTPSuccess)
      JSON.parse(@res.body)
    end

    def update_product(product_id, product)
      @uri = URI "#{SERVER}/products/#{product_id}"
      http_request_json('put', product)
      return true if @res.code == '200'
      JSON.parse(@res.body)
    end

    def create_product(product)
      @uri = URI "#{SERVER}/products"
      http_request_json('post', product)
      JSON.parse(@res.body)
    end

    def delete_product(product_id)
      @uri = URI "#{SERVER}/products/#{product_id}"
      http_request_json('delete')
      (@res.code == '204')
    end
  end
end