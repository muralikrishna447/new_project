require 'spec_helper'

describe User::Google do
  let(:auth) {
    Hashie::Mash.new(
      google: {
        access_token: "ABC",
        code: "ABC123",
        id_token: "ABCDEFG"
      }
    )
  }

  let(:google_app_id){ "123" }
  let(:google_secret){ "123ABC" }
  let(:unconnected_user){ Fabricate.build(:user, google_user_id: nil) }
  let(:connected_user){ Fabricate.build(:user, google_user_id: "123ABC", google_access_token: "ABC123ABC123") }

  let(:google_contact_response) do
    response = double('google_contact_response')
    response.stub(:body).and_return(File.read(Rails.root.join("spec", "api_responses", "google_contacts_response.xml")))
    response
  end

  let(:google_group_response) do
    response = double('google_group_response')
    response.stub(:body).and_return(File.read(Rails.root.join("spec", "api_responses", "google_groups_response.xml")))
    response
  end

  before do
    fake_class = Class.new
    stub_const("Google::APIClient::ClientSecrets", fake_class)
    Google::APIClient::ClientSecrets.stub(:new)
    Google::APIClient::ClientSecrets.any_instance.stub(:to_authorization).and_return(Signet::OAuth2::Client.new)

  end

  describe '#connected_with_google?' do
    it 'should be true if user has google_user_id' do
      connected_user.connected_with_google?.should be true
    end

    it 'should be false if the user has no google_user_id ' do
      unconnected_user.connected_with_google?.should be false
    end
  end

  describe "#gather_google_contacts" do
    before do
      @authorization = Signet::OAuth2::Client.new(access_token: "ABC", refresh_token: "ABC123")
      @authorization.stub(:fetch_access_token!)
      User.stub(:create_authorization).and_return(@authorization)
    end

    let(:contacts){ connected_user.gather_google_contacts(google_app_id, google_secret) }
    context "success" do
      before do
        Signet::OAuth2::Client.any_instance.stub(:fetch_protected_resource).with(uri: "https://www.google.com/m8/feeds/groups/default/full/6?v=3.0").and_return(google_group_response)
        Signet::OAuth2::Client.any_instance.stub(:fetch_protected_resource).with(uri: "https://www.google.com/m8/feeds/contacts/default/full/?max-results=100000&v=3.0&group=http://www.google.com/m8/feeds/groups/test%chefsteps.com/base/6").and_return(google_contact_response)
      end

      it "should fetch group information" do
        Signet::OAuth2::Client.any_instance.should_receive(:fetch_protected_resource).with(uri: "https://www.google.com/m8/feeds/groups/default/full/6?v=3.0").and_return(google_group_response)
        connected_user.gather_google_contacts(google_app_id, google_secret)
      end

      it "should fetch contact information" do
        Signet::OAuth2::Client.any_instance.should_receive(:fetch_protected_resource).with(uri: "https://www.google.com/m8/feeds/contacts/default/full/?max-results=100000&v=3.0&group=http://www.google.com/m8/feeds/groups/test%chefsteps.com/base/6").and_return(google_contact_response)
        connected_user.gather_google_contacts(google_app_id, google_secret)
      end

      it "should return an array" do
        contacts.should be_an_instance_of(Array)
      end

      it "should have the contact emails" do
        contacts.should eq [{:email=>"i.am.trapped.in.a.box@chefsteps.com", :name=>"IM Trapped"}, {:email=>"test.testerson@gmail.com", :name=>"Test Testerson"}, {:email=>"tom.example@gmail.com", :name=>"Tom Example"}]
      end
    end

    # context "error" do
    #   before do
    #     Signet::OAuth2::Client.any_instance.stub(:fetch_protected_resource).with(uri: "https://www.google.com/m8/feeds/groups/default/full/6?v=3.0").and_raise(Signet::AuthorizationError)
    #   end

    #   it "should call fetch_access_token!" do
    #     Signet::OAuth2::Client.any_instance.should_receive(:fetch_access_token!)
    #     connected_user.gather_google_contacts(google_app_id, google_secret)
    #   end
    # end

    context "#google_connect" do
      subject do
        unconnected_user.google_connect({google_user_id: "123", google_refresh_token: "ABC123", google_access_token: "TOKEN"})
        unconnected_user
      end
      its(:google_user_id){ should eq "123"}
      its(:google_refresh_token){ should eq "ABC123"}
      its(:google_access_token){ should eq "TOKEN"}
    end
  end


  describe ".google_connect" do
    let(:user_options){ {email: "dan@chefsteps.com", google_user_id: "1234567890", google_access_token: "TOKEN", name: "Dan Test", google_refresh_token: "REFRESH_TOKEN"} }

    it "should initialize a new record if the user doesn't exist" do
      returned_user = User.google_connect(user_options)
      returned_user.new_record?.should be true
    end

    context "returning user" do
      before do
        @user = Fabricate(:user, user_options)
      end

      it "should return the user if they already exist" do
        returned_user = User.google_connect(user_options)
        returned_user.should eq @user
      end

      it "should not respond true to .new_record?" do
        returned_user = User.google_connect(user_options)
        returned_user.new_record?.should be false
      end
    end
  end

  describe ".gather_info_from_google" do
    before do
      fake_class = Class.new
      stub_const("Google::APIClient", fake_class)
      @google_api_client = double("google_api")
      @google_api_client.stub(:discovered_api).and_return(Hashie::Mash.new(userinfo: { get: "google_method"}))
      @results = Hashie::Mash.new(data: { name: "Dan Test", email: "test@chefsteps.com", id: "123123"})
      @google_api_client.stub(:execute).and_return(@results)
      Google::APIClient.stub(:new).and_return(@google_api_client)
      @authorization = Signet::OAuth2::Client.new(access_token: "ABC", refresh_token: "ABC123")
      @authorization.stub(:fetch_access_token!)
      User.stub(:create_authorization).and_return(@authorization)
    end

    it "should call Google::APIClient" do
      Google::APIClient.should_receive(:new)
      User.gather_info_from_google(auth, google_app_id, google_secret)
    end

    it "should call discovered_api in the client" do
      @google_api_client.should_receive(:discovered_api)
      User.gather_info_from_google(auth, google_app_id, google_secret)
    end

    it "should call create_authorization" do
      User.should_receive(:create_authorization)
      User.gather_info_from_google(auth, google_app_id, google_secret)
    end

    it "should call fetch_access_token!" do
      @authorization.should_receive(:fetch_access_token!)
      User.gather_info_from_google(auth, google_app_id, google_secret)
    end

    it "should call fetch_access_token!" do
      @google_api_client.should_receive(:execute).and_return(@results)
      User.gather_info_from_google(auth, google_app_id, google_secret)
    end

    it "should return a hash" do
      User.gather_info_from_google(auth, google_app_id, google_secret).should be_an_instance_of(Hash)
    end

    it "should have the user information" do
      info = User.gather_info_from_google(auth, google_app_id, google_secret)
      expected_result = {name: "Dan Test", email: "test@chefsteps.com", google_user_id: "123123", google_refresh_token: "ABC123", google_access_token: "ABC"}
      info.should eq expected_result
    end
  end

  describe ".create_authorization" do
    before do
      fake_class = Class.new
      stub_const("Google::APIClient::ClientSecrets", fake_class)
      @client_secrets = double("client_secrets")
      @client_secrets.stub(:to_authorization).and_return(Signet::OAuth2::Client.new)
      Google::APIClient::ClientSecrets.stub(:new).and_return(@client_secrets)
    end

    it "should call Google::APIClient::ClientSecrets" do
      Google::APIClient::ClientSecrets.should_receive(:new)
      User.create_authorization(google_app_id, google_secret)
    end

    it "should return an authorization" do
      User.create_authorization(google_app_id, google_secret).should be_an_instance_of(Signet::OAuth2::Client)
    end
  end
end