describe Api::V0::CirculatorsController do
  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
    @circulator = Fabricate :circulator, notes: 'some notes', circulator_id: '1212121212121212'
    @admin_user = Fabricate :user, email: 'admin@chefsteps.com', password: '123456', name: 'John Doe', role: 'admin'

    @aa = ActorAddress.create_for_circulator @circulator
    @other_circulator = Fabricate :circulator, notes: 'some other notes', circulator_id: '4545454545454545'
    @circulator_user = Fabricate :circulator_user, user: @user, circulator: @circulator, owner: true

    token = ActorAddress.create_for_user(@user, client_metadata: "create").current_token
    request.env['HTTP_AUTHORIZATION'] = token.to_jwt
  end

  it 'should list circulators' do
    get :index

    response.should be_success
    circulators = JSON.parse(response.body)
    circulators.length.should == 1
    circulators[0]['circulatorId'].should == @circulator.circulator_id
    circulators[0]['notes'].should == 'some notes'
    circulators[0]['secretKey'].should == nil
  end

  it 'should create circulator' do
    secret_key = '6b714257175f73150228454466307d16'
    serial_number = 'abc123'
    notes = 'red one'
    post(:create,
         circulator: {
           :serial_number => serial_number,
           :notes => notes,
           :id => '7878787878787878',
           :secret_key => secret_key
         }
    )
    response.should be_success
    returnedCirculator = JSON.parse(response.body)

    returnedCirculator['secretKey'].should == secret_key
    returnedCirculator['serialNumber'].should == serial_number
    returnedCirculator['notes'].should == notes

    circulator = Circulator.where(circulator_id: returnedCirculator['circulatorId']).first
    circulator.should_not be_nil
    circulator.notes.should == notes
    circulator.users.first.should == @user
    circulator.encrypted_secret_key.should_not == secret_key

    circulator_user = CirculatorUser.find_by_circulator_and_user(circulator, @user)
    circulator_user.owner.should be_true

    post :create, circulator: {:serial_number => 'abc123', :notes => 'red one', :id => 'cc78787878787878'}
    response.should be_success
  end

  it 'should not create circulator if bad secret key' do
    secret_key = '1234'
    serial_number = 'abc123'
    notes = 'red one'
    post(:create,
         circulator: {
           :serial_number => serial_number,
           :notes => notes,
           :id => '7878787878787878',
           :secret_key => secret_key
         }
    )
    response.should_not be_success
  end

  it 'should create circulator with no secret key' do
    @circulator
    post(:create,
         circulator: {
           :serial_number => 'abc123',
           :notes => 'red one',
           :id => '7878787878787878'
         }
    )
    response.should be_success
    returnedCirculator = JSON.parse(response.body)
    circ_id = returnedCirculator['circulatorId']
    circulator = Circulator.where(circulator_id: circ_id).first
    circulator.encrypted_secret_key.should == nil
  end

  it 'should prevent duplicate circulators' do
    circulator_id = '8911898989898989'
    post :create, circulator: {:serial_number => 'abc123', :notes => 'red one', :id => circulator_id}
    response.should be_success
    post :create, circulator: {:serial_number => 'abc123', :notes => 'red one', :id => circulator_id}
    response.code.should == '409'
  end

  it 'should assign ownership correctly' do
    post :create, {circulator: {:serial_number => 'abc123', :notes => 'red one', :id => '8911898989898989'}, :owner => false}
    response.should be_success
    returnedCirculator = JSON.parse(response.body)

    circulator = Circulator.where(circulator_id: returnedCirculator['circulatorId']).first
    circulator_user = CirculatorUser.find_by_circulator_and_user(circulator, @user)
    circulator_user.owner.should_not be_true
  end

  it 'should provide a token' do
    post :token, :id => @circulator.circulator_id

    result = JSON.parse(response.body)
    result['token'].should_not be_empty
    token = AuthToken.from_string result['token']
    # TODO - use timecop
    (token['iat'] - Time.now.to_i).abs.should < 2
  end

  it 'should return 400 when token is called without id' do
    post :token
    response.code.should == '400'
  end

  it 'should not provide a token if circulator does not exist' do
    post :token, :id => 'not-a-circulator'
    response.code.should == '403'
  end

  it 'should not provide a token if not a user' do
    post :token, :id => @other_circulator.circulator_id
    response.code.should == '403'
    result = JSON.parse(response.body)
    result['token'].should be_nil
  end

  it 'should delete the circulator' do
    post :destroy, :id => @circulator.circulator_id

    response.should be_success

    result = JSON.parse(response.body)

    Circulator.where(circulator_id: @circulator.circulator_id).first.should be_nil
    CirculatorUser.find_by_circulator_and_user(@circulator, @user).should be_nil
  end

  it 'should not delete a circulator that does not exist' do
    post :destroy, :id => "gibberish"
    response.should_not be_success
    response.code.should == '403'
    result = JSON.parse(response.body)
  end

  it 'should not delete the circulator if not the owner' do
    @circulator_user.owner = false
    @circulator_user.save!

    post :destroy, :id => @circulator.circulator_id
    response.code.should == '403'

    Circulator.find_by_id(@circulator.id).should_not be_nil
  end

  it 'should not delete the circulator if not a user' do
    post :destroy, :id => @other_circulator.id
    response.code.should == '403'

    Circulator.find_by_id(@other_circulator.id).should_not be_nil
  end

  it 'should delete a circulator if admin' do
    token = ActorAddress.create_for_user(@admin_user, client_metadata: "create").current_token
    request.env['HTTP_AUTHORIZATION'] = token.to_jwt
    post :destroy, :id => @circulator.circulator_id
    response.should be_success
    Circulator.find_by_id(@circulator.id).should be_nil
  end

  it 'should return 404 if admin deletes circulator that does not exist' do
    token = ActorAddress.create_for_user(@admin_user, client_metadata: "create").current_token
    request.env['HTTP_AUTHORIZATION'] = token.to_jwt
    post :destroy, :id => 'fake id'
    response.code.should == '404'
  end

  it 'should return 400 if destroy called without id' do
    post :destroy
    response.code.should == '400'
  end
end
