describe Api::V0::CirculatorsController do
  before :each do
    @user = Fabricate :user, id: 160059, email: 'justin@chefsteps.com', password: '123456', name: 'John Doe'
    @circulator = Fabricate :circulator, notes: 'some notes', circulator_id: '1212121212121212'
    @circulator_user = Fabricate :circulator_user, user: @user, circulator: @circulator, owner: true
  end
  
  it 'lists circulators for justin' do
    request.env['HTTP_AUTHORIZATION'] = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE0NDk1MTkzNTUsImEiOiJhMDAwMDBlMjQ5N2FiZGE0Iiwic2VxIjowfQ.WhBeV_ywWSYg3niucaltbw2W1soIq8Ue5IH9NPP3qm4'
    get :index
    response.should be_success
    circulators = JSON.parse(response.body)
    circulators.length.should == 1
    circulators[0]['circulatorId'].should == @circulator.circulator_id
  end
  
  it 'it does not assume no token means justin', :focus => true do
    get :index
    response.code.should == '401'
  end
end
