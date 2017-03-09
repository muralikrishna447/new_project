describe Api::V0::ContentController do
  before :each do
    @supported_environments = YAML.load_file(Rails.root.join('config', 'content_config.yml'))['manifest_endpoints']
  end

  context 'GET /content_config/manifest' do
    it 'supports development environment' do
      get :manifest, content_env: 'development'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['development']
    end

    it 'supports staging environment' do
      get :manifest, content_env: 'staging'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['staging']
    end

    it 'supports beta environment' do
      get :manifest, content_env: 'beta'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['beta']
    end

    it 'supports production environment' do
      get :manifest, content_env: 'production'
      expect(response.status).to eq 302
      expect(response.header["Location"]).to eq @supported_environments['production']
    end

  end
end
