describe Api::V0::Shopping::MarketplaceController do
  before :each do
    @marketplace_guide1 = Fabricate :marketplace_guide, id: 1, guide_id: '3N1qPSrcViOGEYCeaG6io4', url: 'https://test.myshopify.com/products/snake-river-farms-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf', button_text: 'Shop steaks'
    @marketplace_guide2 = Fabricate :marketplace_guide, id: 2, guide_id: 'JIO8hrpTywMCSI40KswcY', url: 'https://store.chocolateyshatner.com/products/72-hour-short-ribs?utm_source=App&utm_medium=post&utm_campaign=short_ribs', button_text: 'Shop short ribs', button_text_line_2: '$84'
    @marketplace_guide3 = Fabricate :marketplace_guide, id: 3, guide_id: '2MH313EsysIOwGcMooSSkk', url: 'https://store.chocolateyshatner.com/products/double-r-ranch-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf', button_text: 'Buy locally', button_text_line_2: '$20-$40', feature_name: 'steak_buy_button'
  end

  context 'GET /marketplace/guide_button' do
    it 'supports existing marketplace guides' do
      get :guide_button, params: {guide_id: '3N1qPSrcViOGEYCeaG6io4'}
      expected = {'line_1' => 'Shop steaks'}
      expect(JSON.parse(response.body)['button']).to eq expected
    end

    it 'supports existing marketplace guides with two-line buttons' do
      get :guide_button, params: {guide_id: 'JIO8hrpTywMCSI40KswcY'}
      expected = {'line_1' => 'Shop short ribs', 'line_2' => '$84'}
      expect(JSON.parse(response.body)['button']).to eq expected
    end

    it 'returns no button when not logged in, when a feature name is set' do
      get :guide_button, params: {guide_id: '2MH313EsysIOwGcMooSSkk'}
      expected = {"request_id"=>nil, "status"=>200}
      expect(JSON.parse(response.body)).to eq expected
    end

    it 'supports beta-flagged guides' do
      @user = Fabricate :user, id: 10001, name: 'customer_1', email: 'customer_1@chefsteps.com', role: 'user'
      BetaFeatureService.stub(:user_has_feature).with(anything(), 'steak_buy_button').and_return(true)
      request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
      get :guide_button, params: {guide_id: '2MH313EsysIOwGcMooSSkk'}
      expected = {'line_1' => 'Buy locally', 'line_2' => '$20-$40'}
      expect(JSON.parse(response.body)['button']).to eq expected
    end
  end

  context 'GET /marketplace/guide_button_redirect' do
    it 'supports existing marketplace guides' do
      get :guide_button_redirect, params: {guide_id: '3N1qPSrcViOGEYCeaG6io4'}
      uri = 'https://test.myshopify.com/products/snake-river-farms-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf'
      expect(JSON.parse(response.body)['redirect']).to eq uri
    end

    it 'returns sso url when apprioriate' do
      @user = Fabricate :user, id: 10001, name: 'customer_1', email: 'customer_1@chefsteps.com', role: 'user'
      request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
      get :guide_button_redirect, params: {guide_id: '3N1qPSrcViOGEYCeaG6io4'}

      uri = 'https://test.myshopify.com/products/snake-river-farms-steak-selection?utm_source=App&utm_medium=post&utm_campaign=chefsteps_app_sales_srf'
      expect(JSON.parse(response.body)['redirect']).to match /https:\/\/test.myshopify.com.account/
    end
  end
end
