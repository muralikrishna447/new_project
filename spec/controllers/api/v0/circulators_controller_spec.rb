describe Api::V0::CirculatorsController do

  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @circulator = Fabricate :circulator, notes: 'some notes'
    other_circulator = Fabricate :circulator, notes: 'some other notes'
    @user.circulators << @circulator

    token = AuthToken.for_user @user
    request.env['HTTP_AUTHORIZATION'] = token.to_s
  end

  it 'should list circulators' do
    get :index

    response.should be_success
    circulators = JSON.parse(response.body)
    circulators.length.should == 1
    circulators[0]['id'].should == @circulator.id
    circulators[0]['notes'].should == 'some notes'
  end

  it 'should create circulator' do
    post :create, circulator: {:serialNumber => 'abc123', :notes => 'red one'}
    returnedCirculator = JSON.parse(response.body)
    circulator = Circulator.find(returnedCirculator['id'])
    circulator.should_not be_nil
    circulator.notes.should == 'red one'
    circulator.users.first.should == @user

    # post :create, circulator: {:serialNumber => 'abc123', :notes => 'red one'}
    # returnedCirculator = JSON.parse(response.body)
    # returnedCirculator['id'].should == circulator.id
  end

  it 'should provide a token' do
    post :token, :id => @circulator.id
    result = JSON.parse(response.body)
    result['token'].should_not be_empty
    token = AuthToken.from_encrypted result['token']
    token['circulator']['id'].should == @circulator.id
  end
end
