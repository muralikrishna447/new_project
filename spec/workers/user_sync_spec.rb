require 'spec_helper'

describe UserSync do
  before :each do
    @user_id = 100
    @user = Fabricate :user, id: @user_id, email: 'johndoe@chefsteps.com'
    @user_sync = UserSync.new(@user_id)

    @referral_code = 'porktato'
    @user_id_with_code = 101
    @user_with_code = Fabricate :user, id: @user_id_with_code, email: 'exenecervenka@chefsteps.com', referral_code: @referral_code
    @user_sync_with_code = UserSync.new(@user_id_with_code)
  end

  describe 'sync premium and joule' do

    it 'should sync premium members who purchased joule' do
      setup_member_joule_purchase true
      setup_joule_purchaser
      setup_premium_user

      stub_post = stub_mailchimp_post({'JL_CONN' => 0, 'JL_EVR_CON' => 0, 'GROUPINGS' => [], 'PREMSTART' => '2018-03-01'})
      @user_sync.sync_mailchimp
      WebMock.assert_requested stub_post
    end

    it 'should not sync joule owner counts if matching at zero against default merge vars' do
      # Test would fail if POST request was made since it's not stubbed
      setup_premium_member_info_with_joule_data_stub(0,0,'subscribed')
      @user_sync.sync_mailchimp
    end

    it 'should not sync if circulator user current circulator count matches non-zero' do
      # 1, 1 in mailchimp
      setup_member_info_with_joule_data_stub(1, 1, 'subscribed')

      # 1, 1 current and ever according to db
      owned_circulator = Fabricate :circulator, serial_number: 'circ123', circulator_id: '1233'
      CirculatorUser.create! user: @user_with_code, circulator: owned_circulator, owner: true

      # Should not post
      @user_sync_with_code.sync_mailchimp
    end

    it 'should sync premium status to mailchimp' do
      setup_member_info_stub('subscribed')
      stub_post = stub_mailchimp_post({'JL_CONN' => 0, 'JL_EVR_CON' => 0, 'GROUPINGS' => [], 'PREMSTART' => '2018-03-01'})
      setup_premium_user
      @user_sync.sync_mailchimp
      WebMock.assert_requested stub_post
    end

    it 'should sync if was CirculatorUser but deleted' do
      # Should get user sync twice, but only post once with 0,1
      stub_mailchimp_post_joule_data(@user_with_code.email, 0, 1)
      Resque.should_receive(:enqueue).with(UserSync, @user_with_code.id).twice()

      # 1, 1 in mailchimp
      setup_member_info_with_joule_data_stub(1, 1, 'subscribed')

      # 0, 1 current and ever according to db
      owned_circulator = Fabricate :circulator, serial_number: 'circ123', circulator_id: '1233'
      cu = CirculatorUser.create! user: @user_with_code, circulator: owned_circulator, owner: true

      # Fake the resque
      @user_sync_with_code.sync_mailchimp

      # Now disconnect joule
      owned_circulator.destroy!

      # Fake the resque
      @user_sync_with_code.sync_mailchimp
    end

    def setup_premium_user
      @user.premium_member = true
      @user.premium_membership_created_at = Date.parse('1st Mar 2018')
      @user.save!
      # since user is read in the constructor need to create a new worker
      @user_sync = UserSync.new(@user_id)
    end

    def setup_member_joule_purchase(in_group)
      setup_member_info_stub('subscribed')
    end

    def setup_joule_purchaser
      @user.joule_purchase_count = 1
      @user.save!
      # since user is read in the constructor need to create a new worker
      @user_sync = UserSync.new(@user_id)
    end
  end

  def setup_member_info_stub(status)
    result = {
      :success_count => 1,
      :data => [{'GROUPINGS' =>[],
                 'merges' =>{'JL_CONN' =>0, 'JL_EVR_CON' =>0},
                 'status' => status }]}
    WebMock.stub_request(:post, 'https://key.api.mailchimp.com/2.0/lists/member-info').
       to_return(:status => 200, :body => result.to_json, :headers => {})
  end

  def setup_premium_member_info_with_joule_data_stub(count, ever_count, status)
    result = {
      :success_count => 1,
      :data => [{'GROUPINGS' =>[],
                 'merges' =>{'JL_CONN' =>count, 'JL_EVR_CON' =>ever_count, 'PREMSTART' => '2015-05-05'},
                 'status' => status }]}
    WebMock.stub_request(:post, 'https://key.api.mailchimp.com/2.0/lists/member-info').
      to_return(:status => 200, :body => result.to_json, :headers => {})
  end

  def setup_member_info_with_joule_data_stub(count, ever_count, status)
    result = {
      :success_count => 1,
      :data => [{'GROUPINGS' =>[],
                 'merges' =>{'JL_CONN' =>count, 'JL_EVR_CON' =>ever_count},
                 'status' => status }]}
    WebMock.stub_request(:post, 'https://key.api.mailchimp.com/2.0/lists/member-info').
       to_return(:status => 200, :body => result.to_json, :headers => {})
  end


  def setup_member_info_not_in_mailchimp_stub
    result = {'success_count' =>0, 'error_count' =>1, 'errors' =>[{'email' =>{'email' => 'a@b.com'}, 'error' => 'The id passed does not exist on this list', 'code' =>232}], 'data' =>[]}
    WebMock.stub_request(:post, 'https://key.api.mailchimp.com/2.0/lists/member-info').
       to_return(:status => 200, :body => result.to_json, :headers => {})
  end

  def setup_member_info_unsubscribed_stub
    result = {'success_count' =>1, 'error_count' =>0,
              'errors' =>[], 'data' =>[{'email' => 'first@chocolateyshatner.com',
                                        'status' => 'unsubscribed'}]}

    WebMock.stub_request(:post, 'https://key.api.mailchimp.com/2.0/lists/member-info').
      with(:body => '{"apikey":"test-api-key","id":"test-list-id","emails":[{"email":"johndoe@chefsteps.com"}]}').
      to_return(:status => 200, :body => result.to_json, :headers => {})
  end

  def stub_mailchimp_post(merge_vars)
    body = {:apikey => 'test-api-key', :id => 'test-list-id', :email => {:email => 'johndoe@chefsteps.com'}, :replace_interests => false, :merge_vars => merge_vars}

    WebMock.stub_request(:post, 'https://key.api.mailchimp.com/2.0/lists/update-member').
        with(:body => body.to_json).
        to_return(:status => 200, :body => '', :headers => {})
  end

  def stub_mailchimp_post_joule_data(email, count, ever_count)
    WebMock.stub_request(:post, 'https://key.api.mailchimp.com/2.0/lists/update-member').
      with(:body => "{\"apikey\":\"test-api-key\",\"id\":\"test-list-id\",\"email\":{\"email\":\"#{email}\"},\"replace_interests\":false,\"merge_vars\":{\"JL_CONN\":#{count},\"JL_EVR_CON\":#{ever_count},\"GROUPINGS\":[]}}").
      to_return(:status => 200, :body => '', :headers => {})
  end
end
