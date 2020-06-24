describe Api::V0::IngredientsController do
  
  before :each do
    @ingredient1 = Fabricate :ingredient, title: 'Ingredient 1'
    @ingredient2 = Fabricate :ingredient, title: 'Ingredient 2'
  end

  # GET /api/v0/ingredients
  context 'GET /ingredients' do
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

  # GET /api/v0/ingredients/:id
  it 'should return a single ingredient' do
    get :index, params: {id: @ingredient1.id}
    response.should be_success

    ingredient = JSON.parse(response.body).first

    ingredient['title'].should == 'Ingredient 1'
    ingredient['description'].should == nil
    ingredient['image'].should == nil
    ingredient['url'].should == 'http://test.host/ingredients/ingredient-1'
  end
end