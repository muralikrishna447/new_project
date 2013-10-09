require 'spec_helper'

describe AssembliesController, "#get" do

  context 'user is not logged in' do
    let!(:user) { Fabricate(:user, id: 29) }
    let!(:assembly) { Fabricate(:assembly, title: "Clummy", assembly_type: "Course", price: 39.00, published: true ) }
    let!(:landing_page) { Fabricate(:page, title: "Clummy LP", content: "You so clummy", primary_path: "/courses/clummy") }

=begin
   before do
      sign_in user
    end
=end


    it 'redirects to landing page' do
      get :show, id: 'clummy'
      expect(response.status).to eq(302)
    end

    it 'computes discounted price' do
      get :landing, id: 'clummy', coupon: 'a1b71d389a50'
      expect(assigns(:discounted_price)).to eq(29)
      expect(session[:coupon]).to eq('a1b71d389a50')
    end

  end


end
