describe UserSync do
  before :each do
    @user_id = 100
    @user = Fabricate :user, id: @user_id, email: 'johndoe@chefsteps.com'
    @user_sync = UserSync.new(@user_id)
  end

  describe 'sync premium' do

    it 'should not set premium status in mailchimp for non-premium member' do
      setup_member_info false
      # Test would fail if POST request was made since it's not stubbed
      @user_sync.sync_mailchimp({premium: true})
    end

    it 'should not re-sync premium status to mailchimp', focus: true do
      setup_member_info true
      setup_premium_user
      # Test would fail if POST request was made since it's not stubbed
      @user_sync.sync_mailchimp({premium: true})
    end

    it 'should throw if mailchimp is premium and database is not' do
      setup_member_info true
      # Test would fail if POST request was made since it's not stubbed
      expect {@user_sync.sync_mailchimp({premium: true})}.to raise_exception
    end

    it 'should sync premium status to mailchimp' do
      setup_member_info false
      stub_post = WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/update-member").
        with(:body => "{\"apikey\":\"test-api-key\",\"id\":\"test-list-id\",\"email\":{\"email\":\"johndoe@chefsteps.com\"},\"merge_vars\":{\"groupings\":[{\"id\":\"test-purchase-group-id\",\"groups\":[\"Premium Member\"]}]}}").
        to_return(:status => 200, :body => "", :headers => {})

      setup_premium_user
      @user_sync.sync_mailchimp({premium: true})

      WebMock.assert_requested stub_post
    end

    it 'should not sync premium status to mailchimp when user is not in mailchimp' do
      setup_member_info_not_in_mailchimp
      @user_sync.sync_mailchimp({premium: true})
    end

    def setup_member_info (premium)
      result = {:success_count => 1, :data => [{"GROUPINGS"=>[{"id"=>'test-purchase-group-id', "name"=>"Doesn't matter", "groups"=>[{"name"=>"Premium Member", "interested"=>premium}]}]}]}
      WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/member-info").
         with(:body => "{\"apikey\":\"test-api-key\",\"id\":\"test-list-id\",\"emails\":[{\"email\":\"johndoe@chefsteps.com\"}]}").
         to_return(:status => 200, :body => result.to_json, :headers => {})
    end

    def setup_member_info_not_in_mailchimp
      WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/member-info").
         with(:body => "{\"apikey\":\"test-api-key\",\"id\":\"test-list-id\",\"emails\":[{\"email\":\"johndoe@chefsteps.com\"}]}").
         to_return(:status => 200, :body => {:success_count => 0}.to_json, :headers => {})
    end

    def setup_premium_user
      @user.premium_member = true
      @user.save!
      # since user is read in the constructor need to create a new worker
      @user_sync = UserSync.new(@user_id)
    end
  end
end
