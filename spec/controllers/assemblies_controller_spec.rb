require 'spec_helper'

describe AssembliesController, "#get" do

  context 'user is not logged in' do
    let!(:user) { Fabricate(:user, id: 29) }
    let!(:assembly) { Fabricate(:assembly, title: "Clummy", assembly_type: "Course", price: 147.47, published: true ) }
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
  end
end
