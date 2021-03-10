describe Api::V0::IngredientsController do
  include Docs::V0::Ingredients::Api
  
  before :each do
    @ingredient1 = Fabricate :ingredient, title: 'Ingredient 1'
    @ingredient2 = Fabricate :ingredient, title: 'Ingredient 2'
  end

  describe 'GET #index' do
    include Docs::V0::Ingredients::Index
    # GET /api/v0/ingredients
    context 'GET /ingredients', :dox do
      it 'should return an array of ingredients' do
        get :index
        response.should be_success

        ingredient = JSON.parse(response.body).first

        ingredient['title'].should == 'Ingredient 1'
        ingredient['description'].should == nil
        ingredient['image'].should == nil
        ingredient['url'].should == 'http://test.host/ingredients/ingredient-1'
      end
    end
  end

  describe 'GET #show' do
    include Docs::V0::Ingredients::Show
    # GET /api/v0/ingredients/:id
    it 'should return a single ingredient', :dox do
      get :show, params: {id: @ingredient1.id}
      response.should be_success

      ingredient = JSON.parse(response.body)

      ingredient['title'].should == 'Ingredient 1'
      ingredient['description'].should == nil
      ingredient['image'].should == nil
      ingredient['url'].should == 'http://test.host/ingredients/ingredient-1'
    end
  end
end
