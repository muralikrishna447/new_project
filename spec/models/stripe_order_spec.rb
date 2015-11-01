require 'spec_helper'

describe StripeOrder do
  before :each do
    @user = Fabricate(:user, name: 'Joe Example', email: 'test@example.com', stripe_id: '000')
    @circulator_sale = {
      circulator_sale: true,
      premium_discount: false,
      price: '200',
      description: 'Circulator',
      gift: false,
      token: 'ABC123',
      shipping_address_name: 'Ship To',
      shipping_address_line1: '123 Any Street',
      shipping_address_city: 'Any Town',
      shipping_address_state: 'WA',
      shipping_address_zip: '98101',
      shipping_address_country: 'US',
      billing_address_name: 'Bill To',
      billing_address_line1: '123 Any Street',
      billing_address_city: 'Any Town',
      billing_address_state: 'WA',
      billing_address_zip: '98101',
      billing_address_country: 'US',
      circulator_base_price: '200',
      premium_base_price: '50',
      circulator_tax_code: 'TPP',
      circulator_discount: '30',
      premium_tax_code: 'ODD',
      tax_amount: '7'
    }
    @circ_premium_price = {
      circulator_sale: true,
      premium_discount: true,
      price: '200',
      description: 'Circulator',
      gift: false,
      token: 'ABC123',
      shipping_address_name: 'Ship To',
      shipping_address_line1: '123 Any Street',
      shipping_address_city: 'Any Town',
      shipping_address_state: 'WA',
      shipping_address_zip: '98101',
      shipping_address_country: 'US',
      billing_address_name: 'Bill To',
      billing_address_line1: '123 Any Street',
      billing_address_city: 'Any Town',
      billing_address_state: 'WA',
      billing_address_zip: '98101',
      billing_address_country: 'US',
      circulator_base_price: '200',
      premium_base_price: '50',
      circulator_tax_code: 'TPP',
      circulator_discount: '30',
      premium_tax_code: 'ODD',
      tax_amount: '7'
    }
    @premium_sale = {
      circulator_sale: false,
      premium_discount: false,
      price: '50',
      description: 'Premium',
      gift: false,
      token: 'ABC123',
      circulator_base_price: '200',
      premium_base_price: '50',
      circulator_tax_code: 'TPP',
      circulator_discount: '30',
      premium_tax_code: 'ODD',
      tax_amount: '7'
    }
    @stripe_circulator_order = Fabricate(:stripe_order, idempotency_key: 'CS123', user_id: @user.id, data: @circulator_sale)
    @stripe_circulator_discount = Fabricate(:stripe_order, idempotency_key: 'CS123', user_id: @user.id, data: @circ_premium_price)
    @premium_order = Fabricate(:stripe_order, idempotency_key: 'CS321', user_id: @user.id, data: @premium_sale)
    AvaTax::TaxService.any_instance.stub(:get).and_return({'TotalTaxable' => '2', 'TotalTax' => '0.07'})
  end

  context "stripe_order" do
    it "should return the stripe hash" do
      order = @stripe_circulator_order.stripe_order
      order.should include(currency: 'usd', email: 'test@example.com', customer: '000')
      order.should include(:shipping, :items, :metadata)
    end
  end

  context "stripe_shipping" do
    it "should return an address if it is a circulator sale" do
      order = @stripe_circulator_order.stripe_shipping
      order.should include(name: 'Ship To', address: {line1: '123 Any Street', city: 'Any Town', state: 'WA', postal_code: '98101', country: 'US'})
    end

    it "should return nothing if it isn't a circulator sale" do
      order = @premium_order.stripe_shipping
      order.should == nil
    end
  end

  context 'stripe_items' do
    it "should create a line item and discount if it is a discount order" do
      items = @stripe_circulator_discount.stripe_items
      items.length.should == 3
      items[0].should include(amount: '200', currency: 'usd', description: 'Joule Circulator', parent: 'cs10001', quantity: 1, type: 'sku')
      items[1].should include(amount: '30',  currency: 'usd', description: 'ChefSteps Premium Joule Discount', quantity: 1, type: 'discount')
    end

    it "should create a line item and premium if it is a joule order" do
      items = @stripe_circulator_order.stripe_items
      items.length.should == 3
      items[0].should include(amount: '200', currency: 'usd', description: 'Joule Circulator', parent: 'cs10001', quantity: 1, type: 'sku')
      items[1].should include(amount: '0', currency: 'usd', description: 'ChefSteps Premium', parent: 'cs10002', quantity: 1, type: 'sku')
    end

    it "should create a line item with just premium if it is just a premium order" do
      items = @premium_order.stripe_items
      items.length.should == 2
      items[0].should include(amount: '50', description: 'ChefSteps Premium', currency: 'usd', quantity: 1, parent: 'cs10002', type: 'sku')
    end

    it "should incldue the tax" do
      items = @premium_order.stripe_items
      items.length.should == 2
      items.last.should include(amount: '7', description: 'Sales Tax', currency: 'usd', quantity: nil, parent: nil, type: 'tax')
    end
  end


  context "get_tax" do
    it "should call the tax service get" do
      AvaTax::TaxService.any_instance.should_receive(:get).and_return({'TotalTaxable' => '2', 'TotalTax' => '0.07'})
      @stripe_circulator_discount.get_tax
    end

    it 'should build the tax request hash' do
      AvaTax::TaxService.any_instance.stub(:get).and_return({'TotalTaxable' => '2', 'TotalTax' => '0.07'})
      results = @stripe_circulator_order.get_tax
      results.should include(total_taxable: 200, taxable_amount: 7)
    end
  end

  context 'tax_shipping_addresses' do
    it 'should return shipping address if circulator sale' do
      address = @stripe_circulator_order.tax_shipping_addresses
      address.first.should include(:AddressCode => '01', :Line1 => '123 Any Street')
    end

    it 'should not return a shipping address if premium sale' do
      address = @premium_order.tax_shipping_addresses
      address.should == nil
    end
  end

  context "tax_line_items" do
    it 'should contain the circulator item if it was a circulator sale' do
      line_items = @stripe_circulator_order.tax_line_items
      line_items.length.should == 1
      line_items.first.should include(:LineNo => 1, :ItemCode => 'cs10001', :Qty => 1, :Amount => '200', :DestinationCode => "01", :Description => 'Circulator', :TaxCode => 'TPP')
    end

    it 'should contain the circulator item if it was a circulator sale' do
      line_items = @premium_order.tax_line_items
      line_items.length.should == 1
      line_items.first.should include(:LineNo => 1, :ItemCode => 'cs10002', :Qty => 1, :Amount => '50', :DestinationCode => "01", :Description => 'Premium', :TaxCode => 'ODD')
    end
  end


  context 'send_to_stripe' do
    before :each do
      stripe = double('stripe')
      stripe.stub(:pay).and_return(stripe)
      stripe.stub(:status).and_return('paid')
      StripeOrder.any_instance.stub(:create_or_update_user).and_return
      StripeOrder.any_instance.stub(:get_tax).and_return({taxable_amount: '7'})
      Stripe::Order.stub(:create).and_return(stripe)
    end

    it "should call create_or_update_user" do
      StripeOrder.any_instance.should_receive(:create_or_update_user).and_return
      @stripe_circulator_order.send_to_stripe
    end

    it "should call get_tax" do
      StripeOrder.any_instance.should_receive(:get_tax).and_return({taxable_amount: '7'})
      @stripe_circulator_order.send_to_stripe
    end

    it "should call make_premium_member" do
      User.any_instance.should_receive(:make_premium_member)
      @stripe_circulator_order.send_to_stripe
    end
  end

end
