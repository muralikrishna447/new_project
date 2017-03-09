describe Api::V0::ContentController do
  before :each do
    @supported_environments = {
        'development' => 'http://api.jouleapp.com/manifests/resources.json',
        'staging' => 'https://d1azuiz827qxpe.cloudfront.net/resources/staging/resources.json',
        'beta' => 'https://d1azuiz827qxpe.cloudfront.net/resources/beta/resources.json',
        'production' => 'https://d1azuiz827qxpe.cloudfront.net/resources/latest/resources.json'
    }
  end

  context 'GET /content_config/manifest' do
    it 'supports development environment' do
      get :manifest, content_env: 'development'
      expected = @supported_environments['development']
      expect(JSON.parse(response.body)['manifest_endpoint']).to eq expected
    end

    it 'supports staging environment' do
      get :manifest, content_env: 'staging'
      expected = @supported_environments['staging']
      expect(JSON.parse(response.body)['manifest_endpoint']).to eq expected
    end

    it 'supports beta environment' do
      get :manifest, content_env: 'beta'
      expected = @supported_environments['beta']
      expect(JSON.parse(response.body)['manifest_endpoint']).to eq expected
    end

    it 'supports production environment' do
      get :manifest, content_env: 'production'
      expected = @supported_environments['production']
      expect(JSON.parse(response.body)['manifest_endpoint']).to eq expected
    end

  end
end
