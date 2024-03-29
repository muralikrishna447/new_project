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
      shipping_name: 'Ship To',
      shipping_address_line1: '123 Any Street',
      shipping_address_city: 'Any Town',
      shipping_address_state: 'WA',
      shipping_address_zip: '98101',
      shipping_address_country: 'US',
      billing_name: 'Bill To',
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
      shipping_name: 'Ship To',
      shipping_address_line1: '123 Any Street',
      shipping_address_city: 'Any Town',
      shipping_address_state: 'WA',
      shipping_address_zip: '98101',
      shipping_address_country: 'US',
      billing_name: 'Bill To',
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
      tax_amount: '7',
      billing_name: 'Bill To',
      billing_address_line1: '123 Any Street',
      billing_address_city: 'Any Town',
      billing_address_state: 'WA',
      billing_address_zip: '98101',
      billing_address_country: 'US'
    }
    @stripe_circulator_order = Fabricate(:stripe_order, idempotency_key: 'CS123', user_id: @user.id, data: @circulator_sale)
    @stripe_circulator_discount = Fabricate(:stripe_order, idempotency_key: 'CS123', user_id: @user.id, data: @circ_premium_price)
    @premium_order = Fabricate(:stripe_order, idempotency_key: 'CS321', user_id: @user.id, data: @premium_sale)
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
      order.should include(name: 'Bill To', address: {line1: '123 Any Street', city: 'Any Town', state: 'WA', postal_code: '98101', country: 'US'})
    end
  end

  context 'stripe_items' do
    it "should create a line item and discount if it is a discount order" do
      items = @stripe_circulator_discount.stripe_items
      items.length.should == 2
      items[0].should include(amount: '200', currency: 'usd', description: 'Joule Circulator', parent: 'cs10001', quantity: 1, type: 'sku')
      items[1].should include(amount: -30,  currency: 'usd', description: 'ChefSteps Premium Joule Discount', parent: nil, quantity: 1, type: 'discount')
    end

    it "should create a line item and premium if it is a joule order" do
      items = @stripe_circulator_order.stripe_items
      items.length.should == 1
      items[0].should include(amount: '200', currency: 'usd', description: 'Joule Circulator', parent: 'cs10001', quantity: 1, type: 'sku')
    end

    it "should create a line item with just premium if it is just a premium order" do
      items = @premium_order.stripe_items
      items.length.should == 1
      items[0].should include(amount: '50', description: 'ChefSteps Premium', currency: 'usd', quantity: 1, parent: 'cs10002', type: 'sku')
    end
  end

  context 'send_to_stripe' do
    before :each do
      stripe3 = double('stripe', amount: 9999, status: 'failed', items: [ {amount: 10000, description: 'foo', parent: 'cs10001'}])
      expect(stripe3.status).to eq('failed')

      stripe2 = double('stripe', amount: 9999, status: 'paid', items: [ {amount: 10000, description: 'foo', parent: 'cs10001'}])
      expect(stripe2.status).to eq('paid')

      stripe = double('stripe', amount: 9999, status: 'created', items: [ {amount: 10000, description: 'foo', parent: 'cs10001'}])
      expect(stripe.status).to eq('created')
      stripe.stub(:pay).and_return(stripe2)


      @stripe_user = double('stripe_user')
      @stripe_user.stub(:id).and_return("tok_123")
      StripeOrder.any_instance.stub(:create_or_update_user).and_return(@stripe_user)
      StripeOrder.any_instance.stub(:get_tax).and_return({taxable_amount: '7'})
      Stripe::Order.stub(:create).and_return(stripe)
      StripeOrder.any_instance.stub(:analytics)
    end

    it 'should send out an email' do
      stripe = double('stripe', amount: 9999, status: 'created', items: [ {amount: 10000, description: 'foo', parent: 'cs10001'}])
      stripe.stub(:status).and_return('created')
      stripe3 = double('stripe', amount: 9999, status: 'failed', items: [ {amount: 10000, description: 'foo', parent: 'cs10001'}])
      stripe3.stub(:status).and_return('failed')
      stripe.stub(:pay).and_return(stripe3)
      Stripe::Order.stub(:create).and_return(stripe)
      DeclinedMailer.should_receive(:joule)
      @stripe_circulator_order.send_to_stripe
    end

    it 'should send out an email on error' do
      stripe = double('stripe', amount: 9999, status: 'created', items: [ {amount: 10000, description: 'foo', parent: 'cs10001'}])
      stripe.stub(:status).and_return('created')
      stripe3 = double('stripe', amount: 9999, status: 'failed', items: [ {amount: 10000, description: 'foo', parent: 'cs10001'}])
      stripe3.stub(:status).and_return('failed')
      stripe.stub(:pay).and_return(stripe3)
      Stripe::Order.stub(:create){ raise(Stripe::CardError.new('test', 'test'))}
      DeclinedMailer.should_receive(:joule).and_call_original
      expect { @stripe_circulator_order.send_to_stripe }.to raise_error
    end

    it 'should send out an email on error during collection' do
      stripe = double('stripe', amount: 9999, status: 'created', items: [ {amount: 10000, description: 'foo', parent: 'cs10001'}])
      stripe.stub(:status).and_return('created')
      stripe3 = double('stripe', amount: 9999, status: 'failed', items: [ {amount: 10000, description: 'foo', parent: 'cs10001'}])
      stripe3.stub(:status).and_return('failed')
      stripe.stub(:pay){ raise(Stripe::CardError.new('test', 'test'))}
      Stripe::Order.stub(:create).and_return(stripe)
      DeclinedMailer.should_receive(:joule).and_call_original
      expect { @stripe_circulator_order.send_to_stripe }.to raise_error
    end

    it 'should remove premium' do
      stripe = double('stripe', amount: 9999, status: 'created', items: [ {amount: 10000, description: 'foo', parent: 'cs10001'}])
      stripe.stub(:status).and_return('created')
      stripe3 = double('stripe', amount: 9999, status: 'failed', items: [ {amount: 10000, description: 'foo', parent: 'cs10001'}])
      stripe3.stub(:status).and_return('failed')
      stripe.stub(:pay).and_return(stripe3)
      Stripe::Order.stub(:create).and_return(stripe)
      @user.make_premium_member(1)
      User.any_instance.should_receive(:remove_premium_membership)
      @stripe_circulator_order.send_to_stripe
    end

    it "should call create_or_update_user" do
      StripeOrder.any_instance.should_receive(:create_or_update_user).and_return(@stripe_user)
      @stripe_circulator_order.send_to_stripe
    end

    it "should call analytics" do
      StripeOrder.any_instance.should_receive(:analytics)
      @stripe_circulator_order.send_to_stripe
    end

    it "should call joule_purchased" do
      User.any_instance.should_receive(:joule_purchased)
      @stripe_circulator_order.send_to_stripe
    end

    it "should call make_premium_member if not gift" do
      User.any_instance.should_receive(:make_premium_member)
      @stripe_circulator_order.send_to_stripe
      expect(PremiumGiftCertificate.count).to eq(0)
    end

    it "should create a premium gift certificate if gift" do
      User.any_instance.should_not_receive(:make_premium_member)
      stripe_order = Fabricate(:stripe_order, idempotency_key: 'CS321', user_id: @user.id, data: @premium_sale.merge(gift: true))
      stripe_order.send_to_stripe
      expect(PremiumGiftCertificate.count).to eq(1)
      expect(PremiumGiftCertificate.last.redeemed).to eq(false)
    end
  end

  context 'analytics' do
    before :each do
      @stripe_charge = Hashie::Mash.new(id: '123', amount: 20000, items: [{type: 'sku', parent: 'cs10001', description: 'Circulator', amount: 170000}, {type: 'tax', description: 'Tax', amount: 3000}] )
    end

    it 'should call Analytics.track and GA' do
      Analytics.should_receive(:track).once
      Analytics.should_receive(:identify).once
      Analytics.should_receive(:flush).once
      HTTParty.should_receive(:post).with('https://www.google-analytics.com/debug/collect', anything).twice
        .and_call_original
      HTTParty.should_receive(:post).with('http://www.google-analytics.com/collect', anything).twice

      @stripe_circulator_order.analytics(@stripe_charge)
    end
  end

  context "class methods" do
    before :each do
      circulator = double('stripe_circulator', id: 'cs10001', name: 'Joule Circulator', price: 24900, metadata: {msrp: '29900', tax_code: 'TP0000', premium_price: '22900'})
      premium = double('stripe_circulator', id: 'cs10002', price: 2900, metadata: {msrp: '4900', tax_code: 'OD10001'})
      circ_product = double('stripe_circulator_product', id: 'cs10001', skus: [circulator], shippable: true, name: 'Joule Circulator')
      premium_product = double('stripe_premium_product', id: 'cs10002', skus: [premium], shippable: false, name: 'ChefSteps Premium')
      stripe_product_result = [circ_product, premium_product]
      Stripe::Product.stub(:all).and_return(stripe_product_result)
    end

    context "build_stripe_order_data" do
      let(:params) { {sku: 'cs10001', gift: false, billing_name: 'Bill To', billing_address_line1: '123 Any Street', billing_address_city: 'Any Town', billing_address_state: 'WA', billing_address_zip: '98101', billing_address_country: 'US', shipping_name: 'Ship To', shipping_address_line1: '123 Any Street', shipping_address_city: 'Any Town', shipping_address_state: 'WA', shipping_address_zip: '98101', shipping_address_country: 'US', 'stripeToken' => 'ABC321'}}
      it "should take params and turn them into a data hash" do
        circulator, premium = StripeOrder.stripe_products
        data = StripeOrder.build_stripe_order_data(params, circulator, premium)
        data.should include( sku: 'cs10001', gift: false, billing_name: 'Bill To', billing_address_line1: '123 Any Street', billing_address_city: 'Any Town', billing_address_state: 'WA', billing_address_zip: '98101', billing_address_country: 'US', shipping_name: 'Ship To', shipping_address_line1: '123 Any Street', shipping_address_city: 'Any Town', shipping_address_state: 'WA', shipping_address_zip: '98101', shipping_address_country: 'US', token: 'ABC321')
        data.should include( circulator_sale: false, premium_discount: false, circulator_tax_code: 'TP0000', premium_tax_code: 'OD10001', circulator_base_price: 24900, premium_base_price: 2900 )
      end
    end


    context "stripe_products" do
      it 'should return two objects with the product information' do
        array = StripeOrder.stripe_products
        array.size.should eq 2
        array[0].should include(sku: 'cs10001', title: 'Joule Circulator', price: 24900, msrp: 29900, 'premiumPrice' => 22900, tax_code: 'TP0000', shippable: true)
        array[1].should include(sku: 'cs10002', title: 'ChefSteps Premium', price: 2900, msrp: 4900, tax_code: 'OD10001', shippable: false)
      end
    end
  end
end
