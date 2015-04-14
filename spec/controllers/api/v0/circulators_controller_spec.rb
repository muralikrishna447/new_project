describe Api::V0::CirculatorsController do
  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @circulator = Fabricate :circulator, notes: 'some notes'
    @other_circulator = Fabricate :circulator, notes: 'some other notes'
    @circulator_user = Fabricate :circulator_user, user: @user, circulator: @circulator, owner: true

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

    circulator_user = CirculatorUser.find_by_circulator_and_user(circulator, @user)
    circulator_user.owner.should be_true

    # TODO - will pass once unique constraint is properly enforced
    # post :create, circulator: {:serialNumber => 'abc123', :notes => 'red one'}
    # returnedCirculator = JSON.parse(response.body)
    # returnedCirculator['id'].should == circulator.id
  end

  it 'should create assign ownership correctly' do
    post :create, {circulator: {:serialNumber => 'abc123', :notes => 'red one'}, :owner => false}

    returnedCirculator = JSON.parse(response.body)
    circulator_user = CirculatorUser.find_by_circulator_and_user(returnedCirculator['id'], @user)
    circulator_user.owner.should_not be_true
  end

  it 'should provide a token' do
    post :token, :id => @circulator.id

    result = JSON.parse(response.body)
    result['token'].should_not be_empty
    token = AuthToken.from_encrypted result['token']
    token['circulator']['id'].should == @circulator.id
  end

  it 'should not provide a token if not a user' do
    post :token, :id => @other_circulator.id

    result = JSON.parse(response.body)
    result['status'].should == 401
    result['token'].should be_nil
  end

  it 'should delete the circulator' do
    post :destroy, :id => @circulator.id
    result = JSON.parse(response.body)
    Circulator.find_by_id(@circulator.id).should be_nil
    CirculatorUser.find_by_circulator_and_user(@circulator, @user).should be_nil
  end

  it 'should not delete the circulator if not the owner' do
    @circulator_user.owner = false
    @circulator_user.save!

    post :destroy, :id => @circulator.id
    result = JSON.parse(response.body)
    result['status'].should == 401
    Circulator.find_by_id(@circulator.id).should_not be_nil
  end

  it 'should not delete the circulator if not a user' do
    post :destroy, :id => @other_circulator.id
    result = JSON.parse(response.body)
    result['status'].should == 401
    Circulator.find_by_id(@other_circulator.id).should_not be_nil
  end
end
