describe PagesController do

  describe 'show' do
    it 'errors if page does not exist' do
      get :show, id: 'foobar'
      expect(response.status).to eq(404)
    end

    it 'renders page page' do
      @page = Fabricate :page, title: 'So Pagey', content: 'smuckers'
      get :show, id: @page.slug
      expect(response).to render_template(:show)
    end

  end
end

