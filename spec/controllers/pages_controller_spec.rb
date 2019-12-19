require 'spec_helper'

describe PagesController do

  describe 'show' do
    it 'errors if page does not exist' do
      get :show, id: 'foobar'
      expect(response.status).to eq(404)
    end

    it 'renders page page' do
      @page = Fabricate :page, title: 'So Pagey', content: 'smuckers', published: true
      get :show, id: @page.slug
      expect(response).to render_template(:show)
    end

    it 'redirects a page promotion' do
      @page = Fabricate :page, title: 'Test Promotion', published: true, is_promotion: true, redirect_path: '/joule', discount_id: 'test_discount_id'
      get :show, id: @page.slug
      expect(response).to redirect_to('/joule?discount_id=test_discount_id')
    end

    it 'redirects a promotion and correctly sets parameters' do
      @page = Fabricate :page, title: 'Test Promotion', published: true, is_promotion: true, redirect_path: '/joule?someParam=hello', discount_id: 'test_discount_id'
      get :show, id: @page.slug
      expect(response).to redirect_to('/joule?discount_id=test_discount_id&someParam=hello')
    end

    it 'does not redirect promotion if redirect_path is not set' do
      @page = Fabricate :page, title: 'Test Promotion', published: true, is_promotion: true, redirect_path: nil, discount_id: 'test_discount_id'
      get :show, id: @page.slug
      expect(response).to render_template(:show)
    end

    it 'redirects promotion if redirect_path is set but code is not set' do
      @page = Fabricate :page, title: 'Test Promotion', published: true, is_promotion: true, redirect_path: '/joule', discount_id: nil
      get :show, id: @page.slug
      expect(response).to redirect_to('/joule')
    end

    it 'redirects a page that is not a promotion' do
      @page = Fabricate :page, title: 'Test Promotion', published: true, is_promotion: false, redirect_path: '/joule'
      get :show, id: @page.slug
      expect(response).to redirect_to('/joule')
    end

  end

  describe 'market' do
    it 'should redirect if it is an add to cart' do
      get :market_ribeye, {add_to_cart: true, product_id: 123, quantity: 321}
      expect(response).to redirect_to(multipass_api_v0_shopping_users_path(product_id: 123, quantity: 321))
    end
  end
end
