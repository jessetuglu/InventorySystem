require "net/http"
require "json"
require 'openssl'

class TestHelper
  def self.create_item(t, d, q)
    body = {
      item: {
        title: t,
        description: d,
        quantity: q
      }
    }
    req("/items/new", "Post", body, true)
  end

  def self.create_coll(n)
    body = {
      collection: {
        name: n,
      }
    }
    req("/collections/new", "Post", body, true)
  end

  def self.get_item(id_in)
    body = {
      item: {
        id: id_in
      }
    }
    req("/item", "Get", body)
  end
end

def req(path, protocol, body = nil, read_body = false)
  url = URI("http://localhost:3000" + path)
  http = Net::HTTP.new(url.host, url.port)

  request_str = "Net::HTTP::#{protocol}"
  request = Object.const_get(request_str).new(url)
  request["content-type"] = 'application/json'

  request.body = body.to_json if body
  response = http.request(request)

  return JSON.parse(response.read_body) if read_body
  response
end

def clear_all
  req('/items', "Delete")
  req('/collections', "Delete")
end

def test_create_item_valid
  puts "Test 'test_create_item_valid' RUNNING"
  body = {
    :description => "test_create_item_valid",
    :title => "test_create_item_valid: #{rand(100000)}",
    :quantity => 100,
  }
  resp = req("/items/new", "Post", body)
  raise "Failed: #{resp.read_body}" unless resp.code.to_i == 200
  puts "Test 'test_create_item_valid' PASS"
end

def test_create_item_valid_coll_id
  puts "Test 'test_create_item_valid_coll_id' RUNNING"
  new_col = TestHelper.create_coll("test_create_item_valid_coll_id #{rand(100000)}")
  item_body = {
    :description => "Testing description",
    :title => "Test title: #{rand(100000)}",
    :quantity => 100,
    :collection_id => new_col["collection"]["id"]
  }
  item_resp = req("/items/new", "Post", item_body)
  raise "Failed: #{item_resp.read_body}" unless item_resp.code.to_i == 200
  puts "Test 'test_create_item_valid_coll_id' PASS"
end

def test_update_item_valid_coll_id
  puts "Test 'test_update_item_valid_coll_id' RUNNING"
  new_item = TestHelper.create_item("test_update_item_valid_coll_id: #{rand(100000)}", "", 100)
  new_col = TestHelper.create_coll("test_update_item_valid_coll_id #{rand(100000)}")
  item_body = {
    :id => new_item["item"]["id"],
    :collection_id => new_col["collection"]["id"]
  }
  item_resp = req("/items/update", "Put", item_body)
  raise "Failed: #{item_resp.read_body}" unless item_resp.code.to_i == 200
  puts "Test 'test_update_item_valid_coll_id' PASS"
end

def test_create_item_invalid_quantity
  puts "Test 'test_create_item_invalid_quantity' RUNNING"
  body = {
    :description => "test_create_item_invalid_quantity",
    :title => "test_create_item_invalid_quantity",
    :quantity => -100,
  }
  resp = req("/items/new", "Post", body)
  raise "Failed: #{resp.read_body}" if resp.code.to_i != 422
  puts "Test 'test_create_item_invalid_quantity' PASS"
end

def test_update_item_invalid_quantity
  puts "Test 'test_update_item_invalid_quantity' RUNNING"
  new_item = TestHelper.create_item("test_update_item_invalid_quantity: #{rand(100000)}","",100)
  body = {
    :id => new_item["item"]["id"],
    :quantity => -100,
  }
  resp = req("/items/update", "Put", body)
  raise "Failed: #{resp.read_body}" if resp.code.to_i != 422
  puts "Test 'test_update_item_invalid_quantity' PASS"
end

def test_create_item_invalid_coll
  puts "Test 'test_create_item_invalid_coll' RUNNING"
  body = {
    :description => "test_create_item_invalid_coll",
    :title => "test_create_item_invalid_coll",
    :quantity => 100,
    :collection_id => "yay"
  }
  resp = req("/items/new", "Post", body)
  raise "Failed: #{resp.read_body}" if resp.code.to_i != 422
  puts "Test 'test_create_item_invalid_coll' PASS"
end

def test_update_item_invalid_coll
  puts "Test 'test_update_item_invalid_coll' RUNNING"
  new_item = TestHelper.create_item("test_update_item_invalid_coll #{rand(1000000)}", "", 2)
  body = {
    :id => new_item["item"]["id"],
    :collection_id => "yay"
  }
  resp = req("/items/update", "Put", body)
  raise "Failed: #{resp.read_body}" if resp.code.to_i != 422
  puts "Test 'test_update_item_invalid_coll' PASS"
end

def test_collection_create_valid
  puts "Test 'test_collection_create_valid' RUNNING"
  body = {
    :name => "Testing collection name #{rand(1000000)}"
  }
  resp = req("/collections/new", "Post", body)
  raise "Failed: #{resp.read_body}" unless resp.code.to_i == 200
  puts "Test 'test_collection_create_valid' PASS"
end

def test_collection_add_items
  puts "Test 'test_collection_add_item' RUNNING"
  new_coll = TestHelper.create_coll("test_collection_add_item #{rand(1000000)}")
  body = {
    collection: {
      :id => new_coll["collection"]["id"],
      :items => [
        {:id => TestHelper.create_item("test_collection_add_items #{rand(1000000)}", "", 1)["item"]["id"]},
        {:id => TestHelper.create_item("test_collection_add_items #{rand(1000000)}", "", 1)["item"]["id"]},
        {:id => TestHelper.create_item("test_collection_add_items #{rand(1000000)}", "", 1)["item"]["id"]},
      ]
    }
  }
  resp = req("/collections/add_items", "Put", body)
  raise "Failed: #{resp.read_body}" unless resp.code.to_i == 200
  raise "Failed: Items size is not 3" unless JSON.parse(resp.read_body)["collection"]["items"].length == 3
  puts "Test 'test_collection_add_item' PASS"
end

def test_collection_delete_items
  puts "Test 'test_collection_delete_items' RUNNING"
  new_coll = TestHelper.create_coll("test_collection_delete_items #{rand(1000000)}")
  item_1 = TestHelper.create_item("test_collection_delete_items #{rand(1000000)}", "", 1)["item"]["id"]
  item_2 = TestHelper.create_item("test_collection_delete_items #{rand(1000000)}", "", 1)["item"]["id"]
  body = {
    collection: {
      :id => new_coll["collection"]["id"],
      :items => [
        {:id => item_1},
        {:id => item_2}
      ]
    }
  }
  resp = req("/collections/add_items", "Put", body)
  raise "Failed: Items size is not 2" unless JSON.parse(resp.read_body)["collection"]["items"].length == 2
  resp = req("/collections/delete_items", "Delete", body)
  raise "Failed: #{resp.read_body}" unless resp.code.to_i == 200
  raise "Failed: Items size is not 0" unless JSON.parse(resp.read_body)["collection"]["items"].length == 0
  item_1_check = TestHelper.get_item(item_1)
  raise "Failed: Deep Delete" unless item_1_check.code.to_i == 200
  item_2_check = TestHelper.get_item(item_2)
  raise "Failed: Deep Delete" unless item_2_check.code.to_i == 200
  puts "Test 'test_collection_delete_items' PASS"
end

def test_collection_add_bad_items
  puts "Test 'test_collection_add_bad_items' RUNNING"
  new_coll = TestHelper.create_coll("test_collection_add_bad_items #{rand(1000000)}")
  body = {
    collection: {
      :id => new_coll["collection"]["id"],
      :items => [
        {:id => "dwieddiewd"},
      ]
    }
  }
  resp = req("/collections/add_items", "Put", body)
  raise "Failed: #{resp.read_body}" unless resp.code.to_i == 422
  puts "Test 'test_collection_add_bad_items' PASS"
end

# Clear the DB
clear_all
# Test creating a valid item, w/o collection id
test_create_item_valid
# Test creating a valid item, w collection id
test_create_item_valid_coll_id
# Test updating a valid item, w collection id
test_update_item_valid_coll_id
# Test creating an item, w invalid quantity
test_create_item_invalid_quantity
# Test updating an item, w invalid quantity
test_update_item_invalid_quantity
# Test creating an item, w invalid collection id
test_create_item_invalid_coll
# Test updating an item, w invalid collection id
test_update_item_invalid_coll

# Test creating a valid collection, w/o items
test_collection_create_valid
# Test adding items to collection
test_collection_add_items
# Test deleting items to collection
test_collection_delete_items
# Test adding bad items to collection
test_collection_add_bad_items
