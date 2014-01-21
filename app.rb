require 'pry' 
require 'sinatra'
require 'sinatra/reloader'
require 'pg'

def dbname
  "lab11"
end

def with_db
  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")
  yield c
  c.close
end

get '/' do

  erb :index
end

# The Products machinery:

# Get the index of products
get '/products' do
  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")

  # Get all rows from the products table.
  @products = c.exec_params("SELECT * FROM products;")
  c.close
  erb :products
end

# Get the form for creating a new product
get '/products/new' do
  erb :new_product
end

# POST to create a new product
post '/products' do
  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")

  # Insert the new row into the products table.
  c.exec_params("INSERT INTO products (name, price, description) VALUES ($1,$2,$3)",
                  [params["name"], params["price"], params["description"]])

  # Assuming you created your products table with "id SERIAL PRIMARY KEY",
  # This will get the id of the product you just created.
  new_product_id = c.exec_params("SELECT currval('products_id_seq');").first["currval"]
  c.close
  redirect "/products/#{new_product_id}"
end

# Update a product
post '/products/:id' do
  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")

  # Update the product.
  c.exec_params("UPDATE products SET (name, price, description) = ($2, $3, $4) WHERE products.id = $1 ",
                [params["id"], params["name"], params["price"], params["description"]])
  c.close
  redirect "/products/#{params["id"]}"
end

get '/products/:id/edit' do
  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")
  @product = c.exec_params("SELECT * FROM products WHERE products.id = $1", [params["id"]]).first
  c.close
  erb :edit_product
end
# DELETE to delete a product
post '/products/:id/destroy' do

  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")
  c.exec_params("DELETE FROM products WHERE products.id = $1", [params["id"]])
  c.close
  redirect '/products'
end



 #GET the show page for a particular product
get '/products/:id' do
  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")
  @product = c.exec_params("SELECT * FROM products WHERE products.id = $1;", [params[:id]]).first

   prod_cat = c.exec_params("SELECT category_id FROM product_categories WHERE product_id = $1;", [params["id"]])
 
     @cat = prod_cat.map do |x|
      c.exec_params("SELECT categories.name FROM categories WHERE categories.id = #{x["category_id"]};").values.flatten
      end

    if @cat.empty?
      @cat = ["none"]
    end

   # end
  # puts "@@@@@@@@@@@@@@@@@@@@ prod_cat: #{} @@@@@@@@@@@@@@@@@@@@@@"
  c.close
  erb :product
end










######################################

# The Categories machinery:

# Get the index of categories
get '/categories' do
  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")

  # Get all rows from the categories table.
  @categories = c.exec_params("SELECT * FROM categories;")
  c.close
  erb :categories
end

# Get the form for creating a new product
get '/categories/new' do
  erb :new_category
end

# POST to create a new category
post '/categories' do
  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")

  # Insert the new row into the categories table.
  c.exec_params("INSERT INTO categories (name, description) VALUES ($1,$2)",
                  [params["name"], params["description"]])

  # Assuming you created your categories table with "id SERIAL PRIMARY KEY",
  # This will get the id of the category you just created.
  new_category_id = c.exec_params("SELECT currval('categories_id_seq');").first["currval"]
  c.close
  redirect "/categories/#{new_category_id}"
end

# Update a category
post '/categories/:id' do
  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")

  # Update the category.
  c.exec_params("UPDATE categories SET (name, description) = ($2, $3) WHERE categories.id = $1 ",
                [params["id"], params["name"], params["description"]])


  c.close
  redirect "/categories/#{params["id"]}"
end



get '/categories/:id/edit' do
  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")
  @category = c.exec_params("SELECT * FROM categories WHERE categories.id = $1", [params["id"]]).first
  c.close
  erb :edit_category
end




# DELETE to delete a category
post '/categories/:id/destroy' do

  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")
  c.exec_params("DELETE FROM categories WHERE categories.id = $1", [params["id"]])
  c.close
  redirect '/categories'
end


# GET the show page for a particular category
get '/categories/:id' do
  c = PGconn.new(:host => "localhost", :dbname => dbname, :password => "xennifer")
  @category = c.exec_params("SELECT * FROM categories WHERE categories.id = $1;", [params[:id]]).first
  # Get all rows from the products_category table.
   prod_cat = c.exec_params("SELECT product_id FROM product_categories WHERE category_id = $1;", [params["id"]])
 
   #still need to fix nil case
  # if prod_cat.first['product_id'] == nil
  #    @product = "none"
  #  else
     @prod = prod_cat.map do |x|
      c.exec_params("SELECT products.name FROM products WHERE products.id = #{x["product_id"]};").values.flatten
    end

    if @prod.empty?
      @prod = ["none"]
    end

   # end
  # puts "@@@@@@@@@@@@@@@@@@@@ prod_cat: #{prod_cat.first["product_id"]} @@@@@@@@@@@@@@@@@@@@@@"
  c.close
  erb :category
end