describe Api::V0::ContentController do

  LOCALE_US = 'en-US'
  LOCALE_GB = 'en-GB'
  LOCALE_CA = 'en-CA'

  before :each do
    additional_endpoints = {
      LOCALE_CA => {'production' => {'default' => 'http://ca_manifest_url'}},
      LOCALE_GB => {'beta_group' => 'guides_en_GB','production' => {'default' => 'http://ca_manifest_url'}},
      }
    @supported_environments = Api::V0::ContentController.refresh_endpoints(additional_endpoints)
  end

  context 'GET /content_config/manifest for logged in users' do

    before :each do

      @admin = Fabricate :user, id: 12345, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
      @user_aa = ActorAddress.create_for_user(@admin, client_metadata: "create", actor_type: "User")
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'slim_guides').and_return(false)
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'beta_guides').and_return(false)
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'guides_en_GB').and_return(false)
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'joule_ready').and_return(false)
      token = @user_aa.current_token
      request.env['HTTP_AUTHORIZATION'] = token.to_jwt
      sign_in @admin
    end

    it 'supports development environment for a logged in user' do
      get :manifest, content_env: 'development'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_US]['development']['default']
    end

    it 'supports staging environment for a logged in user' do
      get :manifest, content_env: 'staging'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_US]['staging']['default']
    end

    it 'supports production environment for a logged in user' do
      get :manifest, content_env: 'production'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_US]['production']['default']
    end

    it 'ignores locale for a logged in user not in beta group' do
      get :manifest, content_env: 'production',  locale: LOCALE_GB
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_US]['production']['default']
    end

    it 'supports alternate locale for a logged in user in beta group' do
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'guides_en_GB').and_return(true)
      get :manifest, content_env: 'production',  locale: LOCALE_GB
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_GB]['production']['default']
    end

    it 'supports alternate locale for logged in user when no beta group is required' do
      get :manifest, content_env: 'production', locale: LOCALE_CA
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_CA]['production']['default']
    end

    it 'returns default when locale is not supported and user is logged in' do
      get :manifest, content_env: 'production', locale: 'en-AU'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_US]['production']['default']
    end

    it '404s on bad environment' do
      get :manifest, content_env: 'badenv'
      expect(response.status).to eq 404
    end

    it 'logged in user in joule_ready beta development' do
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'joule_ready').and_return(true)
      get :manifest, content_env: 'development'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq "https://d1x6fm6y1dz4pl.cloudfront.net/resources/protein_picker/development/resources.json"
    end

    it 'logged in user in joule_ready beta staging' do
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'joule_ready').and_return(true)
      get :manifest, content_env: 'staging'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq "https://d1x6fm6y1dz4pl.cloudfront.net/resources/protein_picker/staging/resources.json"
    end

    it 'logged in user in joule_ready beta production' do
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'joule_ready').and_return(true)
      get :manifest, content_env: 'production'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq "https://d1x6fm6y1dz4pl.cloudfront.net/resources/protein_picker/production/resources.json"
    end

    it 'supports alternate locale for a logged in user in joule_ready beta' do
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'joule_ready').and_return(true)
      get :manifest, locale: LOCALE_GB
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq "https://d1x6fm6y1dz4pl.cloudfront.net/resources/protein_picker/production/resources.json"
    end

    it 'logged in user in joule_ready beta and beta_guides no env' do
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'joule_ready').and_return(true)
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'beta_guides').and_return(true)
      get :manifest
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq "https://d1x6fm6y1dz4pl.cloudfront.net/resources/protein_picker/staging/resources.json"
    end

    it 'logged in user in joule_ready beta and beta_guides production' do
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'joule_ready').and_return(true)
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'beta_guides').and_return(true)
      get :manifest, content_env: 'production'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq "https://d1x6fm6y1dz4pl.cloudfront.net/resources/protein_picker/staging/resources.json"
    end

  end


  context 'GET /content_config/manifest for logged in users, with slim guides feature' do

    before :each do
      @supported_environments = YAML.load_file(Rails.root.join('config', 'content_config.yml'))['manifest_endpoints']
      @admin = Fabricate :user, id: 12345, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
      @user_aa = ActorAddress.create_for_user(@admin, client_metadata: "create", actor_type: "User")
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'beta_guides').and_return(false)
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'joule_ready').and_return(false)
      token = @user_aa.current_token
      request.env['HTTP_AUTHORIZATION'] = token.to_jwt
      sign_in @admin
    end

    it '404s on bad environment' do
      get :manifest, content_env: 'badenv'
      expect(response.status).to eq 404
    end
  end

  context 'GET /content_config/manifest for anonymous user' do


    it 'only supports production environment for anonymous user' do
      get :manifest, content_env: 'development'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_US]['production']['default']

      get :manifest, content_env: 'staging'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_US]['production']['default']

      get :manifest, content_env: 'beta'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_US]['production']['default']
    end

    it 'supports alternate locale when no beta group is required' do
      get :manifest, content_env: 'production', locale: LOCALE_CA
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_CA]['production']['default']
    end

    it 'returns default when locale is not supported' do
      get :manifest, content_env: 'production', locale: 'en-AU'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments[LOCALE_US]['production']['default']
    end
  end
end
