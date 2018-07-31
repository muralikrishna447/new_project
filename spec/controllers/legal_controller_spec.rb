require 'spec_helper'

describe LegalController do
  render_views

  describe 'cookie_policy' do

    context 'US geolocation' do
      before :each do
        cookies[:cs_geo] = "{ \"country\": \"US\" }"
      end

      it 'renders English when no language specified' do
        get :cookie_policy
        expect(response.body).to include("CHEFSTEPS COOKIE POLICY")
      end

      it 'renders English when English specified' do
        get :cookie_policy, language: 'English'
        expect(response.body).to include("CHEFSTEPS COOKIE POLICY")
      end

      it 'renders English when invalid language specified' do
        get :cookie_policy, language: 'foobar'
        expect(response.body).to include("CHEFSTEPS COOKIE POLICY")
      end

    end

    context 'CH geolocation' do
      before :each do
        cookies[:cs_geo] = "{ \"country\": \"CH\" }"
      end

      it 'renders German when no language specified' do
        get :cookie_policy
        expect(response.body).to include("COOKIE-GRUNDSÄTZE VON CHEFSTEPS")
      end

      it 'renders French when French specified' do
        get :cookie_policy, language: 'French'
        expect(response.body).to include("POLITIQUE RELATIVE AUX COOKIES CHEFSTEPS")
      end

      it 'renders German when invalid language specified' do
        get :cookie_policy, language: 'foobar'
        expect(response.body).to include("COOKIE-GRUNDSÄTZE VON CHEFSTEPS")
      end

    end

  end
end