require 'spec_helper'

describe SitemapsController, "#get" do

  context 'show' do
    render_views

    # Should be included
    let!(:activity1) { Fabricate(:activity, title: "bummy", published: true)}
    let!(:ingredient1) { Fabricate(:ingredient, title: "yummy")}
    let!(:assembly1) { Fabricate(:assembly, title: "Clummy", assembly_type: "Course", price: 39.00, published: true ) }
    let!(:assembly3) { Fabricate(:assembly, title: "Zummy", assembly_type: "Course", price: 39.00, published: false, show_prereg_page_in_index: true ) }
    let!(:project1) {Fabricate(:assembly, title: "Nummy", assembly_type: "Project", price: 39.00, published: true) }
    let!(:page1) { Fabricate(:page, title: "Frummy", published: true)}
    let!(:page2) { Fabricate(:page, title: "Hummy", published: false)}
    let!(:poll1) { Fabricate(:poll, title: "Crrummy")}
    let!(:upload) { Fabricate(:upload, title: "uCrrummy", approved: true)}

    # Should not be included
    let!(:activity2) { Fabricate(:activity, title: "bummy", published: false)}
    let!(:assembly2) { Fabricate(:assembly, title: "asdf", assembly_type: "Course", price: 39.00, published: false ) }
    let!(:upload2) { Fabricate(:upload, title: "uCrrummsdfsy")}

    it 'has expected activity in sitemap' do
      get :show, {format: :xml}
      expect(response).to be_success
      expect(assigns(:other_routes)).to have_at_least(4).items
      expect(assigns(:main_stuff)).to have(7).items
      expect(response.body).to include("https://www.chefsteps.com/activities/bummy")
      expect(response.body).to include("https://www.chefsteps.com/ingredients/yummy")
      expect(response.body).to include("https://www.chefsteps.com/classes/clummy")
      expect(response.body).to include("https://www.chefsteps.com/classes/zummy")
      expect(response.body).to include("https://www.chefsteps.com/projects/nummy")
      expect(response.body).to include("https://www.chefsteps.com/frummy")
      expect(response.body).to include("https://www.chefsteps.com/uploads/ucrrummy")
      expect(response.body).to_not include("https://chefsteps.com")
      expect(response.body).to_not include("https://www.chefsteps.com/hummy")
    end
  end
end
