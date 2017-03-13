describe Api::V0::ContentController do
  before :each do
    @supported_environments = YAML.load_file(Rails.root.join('config', 'content_config.yml'))['manifest_endpoints']
    @admin = Fabricate :user, id: 12345, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
    @user_aa = ActorAddress.create_for_user(@admin, client_metadata: "create", actor_type: "User")
    BetaFeatureService.stub(:user_has_feature).with(anything(), 'beta_guides')
        .and_return(false)
    token = @user_aa.current_token
    request.env['HTTP_AUTHORIZATION'] = token.to_jwt
  end



  context 'GET /content_config/manifest' do
    it 'supports development environment' do
      sign_in @admin
      get :manifest, content_env: 'development'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['development']
    end

    it 'supports staging environment' do
      sign_in @admin
      get :manifest, content_env: 'staging'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['staging']
    end

    it 'supports beta environment' do
      sign_in @admin
      get :manifest, content_env: 'beta'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['beta']
    end

    it 'supports production environment' do
      sign_in @admin
      get :manifest, content_env: 'production'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['production']
    end

  end
end
