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

    it 'should not set premium status in mailchimp for non-premium member' do
      stub_mailchimp_post(nil,nil)
      setup_member_premium false
      # Test would fail if POST request was made since it's not stubbed
      @user_sync.sync_mailchimp({premium: true})
    end


    it 'should re-sync premium status to mailchimp' do
      setup_member_premium true
      stub_post = stub_mailchimp_post(Rails.configuration.mailchimp[:premium_group_id], UserSync::PREMIUM_GROUP_NAME)
      setup_premium_user
      @user_sync.sync_mailchimp({premium: true})
      WebMock.assert_requested stub_post
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

    it 'should not sync premium status to mailchimp when user has been cleaned from mailchimp' do
      setup_cleaned_member_premium false
      @user_sync.sync_mailchimp({premium: true})
    end

    it 'should sync premium members who purchased joule' do
      setup_member_joule_purchase true
      setup_joule_purchaser
      setup_premium_user

      # TODO - refactor stub method being mindful of parameter order, etc.
      WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/update-member").
        with(:body => "{\"apikey\":\"test-api-key\",\"id\":\"test-list-id\",\"email\":{\"email\":\"johndoe@chefsteps.com\"},\"merge_vars\":{\"groupings\":[{\"id\":\"test-purchase-group-id\",\"groups\":[\"Premium Member\"]},{\"id\":\"test-joule-group-id\",\"groups\":[\"Joule Purchase\"]}]},\"replace_interests\":false}").
        to_return(:status => 200, :body => "", :headers => {})

      @user_sync.sync_mailchimp
    end

    it 'should not set joule purchase in mailchimp for non-joule member' do
      stub_mailchimp_post(nil, nil)
      setup_member_joule_purchase false
      # Test would fail if POST request was made since it's not stubbed
      @user_sync.sync_mailchimp({joule: true})
    end

    it 'should re-sync joule purchase to mailchimp' do
      setup_member_joule_purchase true
      stub_post = stub_mailchimp_post(Rails.configuration.mailchimp[:joule_group_id], UserSync::JOULE_PURCHASE_GROUP_NAME)

      setup_joule_purchaser
      @user_sync.sync_mailchimp({joule: true})
      WebMock.assert_requested stub_post
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

    it 'should handle unsubscribed members' do
      setup_member_unsubscribed
      setup_premium_user
      @user_sync.sync_mailchimp({premium: true})
    end

    it 'should not sync joule owner counts if matching at zero against default merge vars' do
      # Test would fail if POST request was made since it's not stubbed
      setup_member_premium false
      @user_sync.sync_mailchimp({joule_data: true})
    end

    context '!CsSpree.front_end_enabled?' do
      before(:each){
        CsSpree.should_receive(:front_end_live?).and_return(false)
      }

      it 'should sync if circulator user current circulator counts mismatch' do
        # Should post 1,1
        stub_mailchimp_post_joule_data(@user.email, 1, 1, @referral_code)
        Resque.should_receive(:enqueue).with(UserSync, @user.id)

        # Since this is first circulator, we would expect referral code created too
        Shopify::Customer.should_receive(:find_or_create_referral_code_for_user).and_return(@referral_code)

        # 0, 0 in mailchimp
        setup_member_info_with_joule_data(0, 0, '', 'subscribed')

        # 1, 1 current and ever according to db
        owned_circulator = Fabricate :circulator, serial_number: 'circ123', circulator_id: '1233'
        cu = CirculatorUser.create! user: @user, circulator: owned_circulator, owner: true
        cu.run_callbacks(:commit)

        # Fake the resque
        @user_sync.sync_mailchimp({joule_data: true})
      end
    end

    context 'CsSpree.front_end_enabled?' do
      before(:each){
        CsSpree.should_receive(:front_end_live?).and_return(true)
      }
      it 'should sync if circulator user current circulator counts mismatch' do
        # Should post 1,1
        stub_mailchimp_post_joule_data(@user.email, 1, 1, @referral_code)
        Resque.should_receive(:enqueue).with(UserSync, @user.id)

        # Since this is first circulator, we would expect referral code created too
        CsSpree::Sync.should_receive(:ensure_share_joule_code_for_user).and_return(@referral_code)

        # 0, 0 in mailchimp
        setup_member_info_with_joule_data(0, 0, '', 'subscribed')

        # 1, 1 current and ever according to db
        owned_circulator = Fabricate :circulator, serial_number: 'circ123', circulator_id: '1233'
        cu = CirculatorUser.create! user: @user, circulator: owned_circulator, owner: true
        cu.run_callbacks(:commit)

        # Fake the resque
        @user_sync.sync_mailchimp({joule_data: true})
      end
    end

    it 'should not sync if circulator user current circulator count matches non-zero' do
      # 1, 1 in mailchimp
      setup_member_info_with_joule_data(1, 1, @referral_code, 'subscribed')

      # 1, 1 current and ever according to db
      owned_circulator = Fabricate :circulator, serial_number: 'circ123', circulator_id: '1233'
      CirculatorUser.create! user: @user_with_code, circulator: owned_circulator, owner: true

      # Should not post
      @user_sync_with_code.sync_mailchimp({joule_data: true})
    end

    it 'should sync if was CirculatorUser but deleted' do
      # Should get user sync twice, but only post once with 0,1
      stub_mailchimp_post_joule_data(@user_with_code.email, 0, 1, @referral_code)
      Resque.should_receive(:enqueue).with(UserSync, @user_with_code.id).twice()

      # 1, 1 in mailchimp
      setup_member_info_with_joule_data(1, 1, @referral_code, 'subscribed')

      # 0, 1 current and ever according to db
      owned_circulator = Fabricate :circulator, serial_number: 'circ123', circulator_id: '1233'
      cu = CirculatorUser.create! user: @user_with_code, circulator: owned_circulator, owner: true
      cu.run_callbacks(:commit)

      # Fake the resque
      @user_sync_with_code.sync_mailchimp({joule_data: true})

      # Now disconnect joule
      owned_circulator.destroy!

      # Fake the resque
      @user_sync_with_code.sync_mailchimp({joule_data: true})
    end

    def setup_member_premium(in_group)
      setup_member_info(Rails.configuration.mailchimp[:premium_group_id],
        UserSync::PREMIUM_GROUP_NAME, in_group, 'subscribed')
    end

    def setup_cleaned_member_premium(in_group)
      setup_member_info(Rails.configuration.mailchimp[:premium_group_id],
        UserSync::PREMIUM_GROUP_NAME, in_group, 'cleaned')
    end

    def setup_premium_user
      @user.premium_member = true
      @user.save!
      # since user is read in the constructor need to create a new worker
      @user_sync = UserSync.new(@user_id)
    end

    def setup_member_joule_purchase(in_group)
      setup_member_info(Rails.configuration.mailchimp[:joule_group_id],
        UserSync::JOULE_PURCHASE_GROUP_NAME, in_group, 'subscribed')
    end

    def setup_joule_purchaser
      @user.joule_purchase_count = 1
      @user.save!
      # since user is read in the constructor need to create a new worker
      @user_sync = UserSync.new(@user_id)
    end
  end

  def setup_member_info(group_id, name, in_group, status)
    result = {
      :success_count => 1,
      :data => [{"GROUPINGS"=>[{"id"=>group_id, "name"=>"Doesn't matter",
                  "groups"=>[{"name"=>name, "interested"=>in_group}]}],
                 "status" => status }]}
    WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/member-info").
       to_return(:status => 200, :body => result.to_json, :headers => {})
  end

  def setup_member_info_with_joule_data(count, ever_count, referral_code, status)
    result = {
      :success_count => 1,
      :data => [{"GROUPINGS"=>[],
                 "merges"=>{"JL_CONN"=>count, "JL_EVR_CON"=>ever_count, "REFER_CODE"=>referral_code},
                 "status" => status }]}
    WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/member-info").
       to_return(:status => 200, :body => result.to_json, :headers => {})
  end


  def setup_member_info_not_in_mailchimp
    result = {"success_count"=>0, "error_count"=>1, "errors"=>[{"email"=>{"email"=>"a@b.com"}, "error"=>"The id passed does not exist on this list", "code"=>232}], "data"=>[]}
    WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/member-info").
       to_return(:status => 200, :body => result.to_json, :headers => {})
  end

  def setup_member_unsubscribed
    result = {"success_count"=>1, "error_count"=>0,
      "errors"=>[], "data"=>[{"email"=>"first@chocolateyshatner.com",
      "status"=>"unsubscribed"}]}

    WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/member-info").
      with(:body => "{\"apikey\":\"test-api-key\",\"id\":\"test-list-id\",\"emails\":[{\"email\":\"johndoe@chefsteps.com\"}]}").
      to_return(:status => 200, :body => result.to_json, :headers => {})
  end

  def stub_mailchimp_post(group_id, name)
    merge_vars = {:groupings => []}
    body = {:apikey => 'test-api-key', :id => 'test-list-id', :email => {:email => 'johndoe@chefsteps.com'}, :merge_vars => merge_vars, :replace_interests => false}
    if group_id
      merge_vars[:groupings] = [{:id => "#{group_id}", :groups => [name]}]
    end
    WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/update-member").
        with(:body => body.to_json).
        to_return(:status => 200, :body => "", :headers => {})
  end

  def stub_mailchimp_post_joule_data(email, count, ever_count, referral_code)
    WebMock.stub_request(:post, "https://key.api.mailchimp.com/2.0/lists/update-member").
      with(:body => "{\"apikey\":\"test-api-key\",\"id\":\"test-list-id\",\"email\":{\"email\":\"#{email}\"},\"replace_interests\":false,\"merge_vars\":{\"JL_CONN\":#{count},\"JL_EVR_CON\":#{ever_count},\"REFER_CODE\":\"#{referral_code}\"}}").
      to_return(:status => 200, :body => "", :headers => {})
  end
end
