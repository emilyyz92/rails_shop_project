require_relative "../rails_helper.rb"

describe "order creation", type: :feature do
  order_helper

  it "only allows users to access page if logged in" do
    page.set_rack_session(user_id: nil)
    visit "/users/1/orders/new"
    expect(current_path).to eq('/')
  end

  it "creates eligible orders after submission" do
    page.set_rack_session(user_id: 1)
    visit "/users/1/orders/new"
    check "Firebolt", select("1", from: "order_count_1")
    check "Weasley's joke wand", select("2", from: "order_count_2")
    click_button "Create Order"
    expect(harry.orders.count).to eq(1)
    expect(harry.orders.last.items.count).to eq(3)
  end
end

describe "orders index", type: :feature do
  order_helper


  it "only allows admin users to access page" do
    page.set_rack_session(user_id: malfoy.id)
    visit orders_path
    expect(page).to have_content("You don't have access")
  end

  it "links to order show page" do
    page.set_rack_session(user_id: headmaster.id)
    visit orders_path
    binding.pry
    expect(page).to have_link("1")
  end
end

describe "orders show", type: :feature do
  order_helper

  it "only allows admin users or users who created the order to view" do
    page.set_rack_session(user_id: malfoy.id)
    visit order_path(order1)
    expect(current_path).to eq('/')
  end

  it "order can be edited or deleted before order is fulfilled" do
    page.set_rack_session(user_id: harry.id)
    visit user_order_path(harry, order1)
    expect(page).to have_content("Edit Order")
    click_button('Delete Order')
    visit user_order_path(harry, order1)
    expect(current_path).to raise_error
  end

  it "allows admin user to fulfill order" do
    page.set_rack_session(user_id: headmaster.id)
    visit order_path(order1)
    click_button('Fulfill Order')
    expect(order1.fulfilled_status).to eq(true)
  end

  it "does not allow standard user to fulfill order" do
    page.set_rack_session(user_id: harry.id)
    visit order_path(order1)
    expect(page).to_not have_button("Fulfill Order")
  end

  it "does not allow user to edit or delete order after order is fulfilled" do
    page.set_rack_session(user_id: headmaster.id)
    visit order_path(order1)
    click_button('Fulfill Order')
    page.set_rack_session(user_id: harry.id)
    visit order_path(order1)
    expect(page).to_not have_link("Edit Order")
    expect(page).to_not have_button("Delete Order")
  end

end
