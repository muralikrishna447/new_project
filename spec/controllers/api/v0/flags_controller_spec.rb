describe Api::V0::FlagsController do
  include Docs::V0::Flags::Api

  ENV["CS_FLAGS"] = "{
    \"US\": {
      \"bannerText\": \"Use the code BLACKFRIDAY for \$30 off Joule through 11/27 [LINK]\",
      \"bannerLink\": \"https://www.chefsteps.com/joule\",
      \"bannerLinkText\": \"THIS LINK\"
    },
    \"CA\": {
      \"bannerText\": \"Use the code BLACKFRIDAY for \$30 off Joule through 11/27 [LINK]\",
      \"bannerLink\": \"https://www.chefsteps.com/joule\",
      \"bannerLinkText\": \"THIS LINK\"
    }
  }"

  describe 'GET #index' do
    include Docs::V0::Flags::Index
    it 'should return flags', :dox do
      get :index
      response.should be_success
      flags_response = JSON.parse(response.body)
      flags_response['flags']['US']['bannerText'].should == "Use the code BLACKFRIDAY for $30 off Joule through 11/27 [LINK]"
    end
  end
end
