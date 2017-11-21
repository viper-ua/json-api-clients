require 'securerandom'
require_relative 'product'

describe Product do
  describe '.find' do
    it 'returns product when exists' do
      product = Product.find(1)
      expect(product).to be_a(Product) # product is an instance of class Product
      expect(product.id).to eq(1)
      expect(product.title).to be_a(String)
      expect(product.description).to be_a(String)
      expect(product.image_url).to be_a(String)
    end

    it "returns nil when doesn't exist" do
      product = Product.find(-1)
      expect(product).to be_nil
    end
  end

  describe '.all' do
    it 'returns all products' do
      products = Product.all
      expect(products).to be_an(Array)
      product = products.first
      expect(product).to be_a(Product) # product is an instance of class Product
      expect(product.id).to eq(1)
      expect(product.title).to be_a(String)
      expect(product.description).to be_a(String)
      expect(product.image_url).to be_a(String)
    end
  end

  describe '.create' do
    it 'returns new product with id when successfully created' do
      title = "Product #{SecureRandom.uuid}" # random unique product title
      product = Product.create(title: title, description: 'Description1', image_url: 'http://example.com/image.png', price: 19.8)
      expect(product).to be_a(Product) # product is an instance of class Product
      expect(product.id).to be_an(Integer)
      expect(product.title).to eq(title)
      expect(product.description).to eq('Description1')
      expect(product.image_url).to eq('http://example.com/image.png')
      expect(product.price.to_f).to eq(19.8)
    end

    it 'returns new product without id with validation errors when not created' do
      product = Product.create(title: '', description: 'Description1')
      expect(product).to be_a(Product)
      expect(product.id).to be_nil
      expect(product.title).to eq('')
      expect(product.description).to eq('Description1')
      expect(product.errors).to eq({"title"=>["can't be blank"], "image_url"=>["can't be blank"], "price"=>["is not a number"]})
    end
  end

  describe '#update' do
    it 'returns true when successfully updated' do
      product = Product.find(1)
      expect(product.update(description: 'Description1')).to be true
    end

    it 'returns false and assigns validation errors when not updated' do
      product = Product.find(1)
      expect(product.update(description: '')).to be false
      expect(product.errors).to eq({"description"=>["can't be blank"]})
    end
  end

  describe '#save' do
    context 'new product' do
      it 'creates new product with valid attributes' do
        product = Product.new
        product.title = "Product #{SecureRandom.uuid}"  # random unique product title
        product.description = 'Description1'
        product.image_url = 'http://example.com/image.png'
        product.price = 19.8
        expect(product.save).to be true
        expect(product.id).to be_an(Integer)
      end

      it 'returns false with invalid attributes and assigns validation errors' do
        product = Product.new
        expect(product.save).to be false
        expect(product.errors).to eq({"title"=>["can't be blank"], "description"=>["can't be blank"], "image_url"=>["can't be blank"], "price"=>["is not a number"]})
      end
    end

    context 'persisted product' do
      it 'updates persisted product' do
        product = Product.find(1)
        product.description = 'Description2'
        expect(product.save).to be true
      end

      it 'returns false with invalid attributes and assigns validation errors' do
        product = Product.find(1)
        product.description = ''
        expect(product.save).to be false
        expect(product.errors).to eq({"description"=>["can't be blank"]})
      end
    end
  end

  describe '#delete' do
    it 'deletes product' do
      title = "Product #{SecureRandom.hex}" # random unique product title
      product = Product.create(title: title, description: 'Description1', image_url: 'http://example.com/image.png', price: 19.8)
      product_id = product.id
      product.delete
      expect(Product.find(product_id)).to be_nil
    end
  end
end
