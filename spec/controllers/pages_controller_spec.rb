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
  end

  describe 'market' do
    it 'should redirect if it is an add to cart' do
      get :market_ribeye, {add_to_cart: true, product_id: 123, quantity: 321}
      expect(response).to redirect_to(multipass_api_v0_shopping_users_path(product_id: 123, quantity: 321))
    end
  end
end
