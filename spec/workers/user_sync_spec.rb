describe UserSync do
  before :each do
    @user_id = 100
    @user = Fabricate :user, id: @user_id, email: 'johndoe@chefsteps.com'
    @user_sync = UserSync.new(@user_id)
  end

  describe 'sync premium' do

    it 'should not set premium status in mailchimp for non-premium member' do
      setup_member_premium false
      # Test would fail if POST request was made since it's not stubbed
      @user_sync.sync_mailchimp({premium: true})
    end

    it 'should not re-sync premium status to mailchimp' do
      setup_member_premium true
      setup_premium_user
      # Test would fail if POST request was made since it's not stubbed
      @user_sync.sync_mailchimp({premium: true})
    end

    it 'should throw if mailchimp is premium and database is not' do
      setup_member_premium true
      # Test would fail if POST request was made since it's not stubbed
      expect {@user_sync.sync_mailchimp({premium: true})}.to raise_exception
    end

    it 'should sync premium status to mailchimp' do
      setup_member_premium false
      stub_post = stub_mailchimp_post(Rails.configuration.mailchimp[:premium_group_id], UserSync::PREMIUM_GROUP_NAME)
      setup_premium_user
      @user_sync.sync_mailchimp({premium: true})
      WebMock.assert_requested stub_post
    end

    it 'should not sync premium status to mailchimp when user is not in mailchimp' do
      setup_member_info_not_in_mailchimp
      @user_sync.sync_mailchimp({premium: true})
    end

    def setup_member_premium(in_group)
      setup_member_info(Rails.configuration.mailchimp[:premium_group_id], UserSync::PREMIUM_GROUP_NAME, in_group)
    end

    def setup_premium_user
      @user.premium_member = true
      @user.save!
      # since user is read in the constructor need to create a new worker
      @user_sync = UserSync.new(@user_id)
    end
  end

  describe 'sync joule purchase' do

    it 'should not set joule purchase in mailchimp for non-joule member' do
      setup_member_joule_purchase false
      # Test would fail if POST request was made since it's not stubbed
      @user_sync.sync_mailchimp({joule: true})
    end

    it 'should not re-sync joule purchase to mailchimp' do
      setup_member_joule_purchase true
      setup_joule_purchaser
      # Test would fail if POST request was made since it's not stubbed
      @user_sync.sync_mailchimp({joule: true})
    end

    it 'should throw if mailchimp is joule purchaser and database is not' do
      setup_member_joule_purchase true
      # Test would fail if POST request was made since it's not stubbed
      expect {@user_sync.sync_mailchimp({joule: true})}.to raise_exception
    end

    it 'should sync joule purchase to mailchimp' do
      setup_member_joule_purchase false
      stub_post = stub_mailchimp_post(Rails.configuration.mailchimp[:joule_group_id], UserSync::JOULE_PURCHASE_GROUP_NAME)
      setup_joule_purchaser
      @user_sync.sync_mailchimp({joule: true})
      WebMock.assert_requested stub_post
    end

    it 'should not sync joule purchase to mailchimp when user is not in mailchimp' do
      setup_member_info_not_in_mailchimp
      @user_sync.sync_mailchimp({premium: true})
    end

    def setup_member_joule_purchase(in_group)
      setup_member_info(Rails.configuration.mailchimp[:joule_group_id], UserSync::JOULE_PURCHASE_GROUP_NAME, in_group)
    end

    def setup_joule_purchaser
      @user.joule_purchase_count = 1
      @user.save!
      # since user is read in the constructor need to create a new worker
      @user_sync = UserSync.new(@user_id)
    end
  end

  def setup_member_info(group_id, name, in_group)
    result = {:success_count => 1, :data => [{"GROUPINGS"=>[{"id"=>group_id, "name"=>"Doesn't matter", "groups"=>[{"name"=>name, "interested"=>in_group}]}]}]}
    WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/member-info").
       with(:body => "{\"apikey\":\"test-api-key\",\"id\":\"test-list-id\",\"emails\":[{\"email\":\"johndoe@chefsteps.com\"}]}").
       to_return(:status => 200, :body => result.to_json, :headers => {})
  end

  def setup_member_info_not_in_mailchimp
    WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/member-info").
       with(:body => "{\"apikey\":\"test-api-key\",\"id\":\"test-list-id\",\"emails\":[{\"email\":\"johndoe@chefsteps.com\"}]}").
       to_return(:status => 200, :body => {:success_count => 0}.to_json, :headers => {})
  end

  def stub_mailchimp_post(group_id, name)
    WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/update-member").
        with(:body => "{\"apikey\":\"test-api-key\",\"id\":\"test-list-id\",\"email\":{\"email\":\"johndoe@chefsteps.com\"},\"merge_vars\":{\"groupings\":[{\"id\":\"#{group_id}\",\"groups\":[\"#{name}\"]}]}}").
        to_return(:status => 200, :body => "", :headers => {})
  end
end
