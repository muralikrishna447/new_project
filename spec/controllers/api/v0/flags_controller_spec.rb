describe Api::V0::FlagsController do

  ENV["CS_FLAGS"] = "{
    \"US\": {
      \"bannerText\": \"Use the code BLACKFRIDAY for \$30 off Joule through 11/27 [LINK]\",
      \"bannerLink\": \"https://www.chefsteps.com/joule\",
      \"bannerLinkText\": \"THIS LINK\"
    }
  }"

  it 'should return flags' do
    get :index
    response.should be_success
    flags_response = JSON.parse(response.body)
    flags_response['flags']['US']['bannerText'].should == "Use the code BLACKFRIDAY for $30 off Joule through 11/27 [LINK]"
  end
end
