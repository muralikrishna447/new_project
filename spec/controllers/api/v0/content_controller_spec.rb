describe Api::V0::ContentController do


  context 'GET /content_config/manifest for logged in users' do

    before :each do
      @supported_environments = YAML.load_file(Rails.root.join('config', 'content_config.yml'))['manifest_endpoints']
      @admin = Fabricate :user, id: 12345, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
      @user_aa = ActorAddress.create_for_user(@admin, client_metadata: "create", actor_type: "User")
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'slim_guides').and_return(false)
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'beta_guides').and_return(false)
      token = @user_aa.current_token
      request.env['HTTP_AUTHORIZATION'] = token.to_jwt
      sign_in @admin
    end

    it 'supports development environment for a logged in user' do
      get :manifest, content_env: 'development'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['development']['default']
    end

    it 'supports staging environment for a logged in user' do
      get :manifest, content_env: 'staging'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['staging']['default']
    end

    it 'supports production environment for a logged in user' do
      get :manifest, content_env: 'production'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['production']['default']
    end

    it '404s on bad environment' do
      get :manifest, content_env: 'badenv'
      expect(response.status).to eq 404
    end
  end


  context 'GET /content_config/manifest for logged in users, with slim guides feature' do

    before :each do
      @supported_environments = YAML.load_file(Rails.root.join('config', 'content_config.yml'))['manifest_endpoints']
      @admin = Fabricate :user, id: 12345, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
      @user_aa = ActorAddress.create_for_user(@admin, client_metadata: "create", actor_type: "User")
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'slim_guides').and_return(true)
      BetaFeatureService.stub(:user_has_feature).with(@admin, 'beta_guides').and_return(false)
      token = @user_aa.current_token
      request.env['HTTP_AUTHORIZATION'] = token.to_jwt
      sign_in @admin
    end

    it 'supports development environment for a logged in user' do
      get :manifest, content_env: 'development'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['development']['slim_guides']
    end

    it 'supports staging environment for a logged in user' do
      get :manifest, content_env: 'staging'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['staging']['slim_guides']
    end

    it 'supports production envronment for a logged in user' do
      get :manifest, content_env: 'production'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['production']['slim_guides']
    end

    it '404s on bad environment' do
      get :manifest, content_env: 'badenv'
      expect(response.status).to eq 404
    end
  end

  context 'GET /content_config/manifest for anonymous user' do

    before :each do
      @supported_environments = YAML.load_file(Rails.root.join('config', 'content_config.yml'))['manifest_endpoints']
    end

    it 'only supports production environment for anonymous user' do
      get :manifest, content_env: 'development'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['production']['default']

      get :manifest, content_env: 'staging'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['production']['default']

      get :manifest, content_env: 'beta'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['production']['default']
    end

  end

end
