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

    context 'No geolocation, country requested by query string parameters' do

      it 'renders for each country_code' do
        countries = ['US', 'CA', 'GB', 'DK', 'FI', 'FR', 'DE', 'IE', 'IT', 'NL', 'NO', 'ES', 'SE', 'CH', 'EU']
        countries.each { |country|
          get :cookie_policy, country_code: country
          expect(response).to be_success
          expect(response.body).to include("Cookie Policy")
        }
      end

    end

  end
end