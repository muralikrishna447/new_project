require 'spec_helper'

describe SitemapsController, "#get" do

  context 'show' do
    render_views

    # Should be included
    let!(:activity1) { Fabricate(:activity, title: "bummy", published: true)}
    let!(:ingredient1) { Fabricate(:ingredient, title: "yummy", text_fields: "now is the time for all good men to come to the aid of their respective parties and to the republic for which it stands one nation under god individisble")}
    let!(:ingredient2) { Fabricate(:ingredient, title: "mummy", text_fields: "now is the time")}
    let!(:assembly1) { Fabricate(:assembly, title: "Clummy", assembly_type: "Course", price: 39.00, published: true ) }
    let!(:assembly3) { Fabricate(:assembly, title: "Zummy", assembly_type: "Course", price: 39.00, published: false, show_prereg_page_in_index: true ) }
    let!(:page1) { Fabricate(:page, title: "Frummy", published: true)}

    # Should not be included
    let!(:activity2) { Fabricate(:activity, title: "bummy", published: false)}
    let!(:assembly2) { Fabricate(:assembly, title: "asdf", assembly_type: "Course", price: 39.00, published: false ) }
    let!(:ugc_user) {Fabricate(:user, id: 1)}
    let!(:activity3) { Fabricate(:activity, title: "rummy", published: true, creator: ugc_user)}
    let!(:page2) { Fabricate(:page, title: "Hummy", published: false)}

    it 'has expected activity in sitemap' do
      get :show, params: {format: :xml}
      expect(response).to be_success
      expect(assigns(:other_routes)).to have_at_least(4).items
      expect(assigns(:main_stuff)).to have(5).items
      expect(response.body).to include("https://www.chefsteps.com/activities/bummy")
      expect(response.body).to include("https://www.chefsteps.com/ingredients/yummy")
      expect(response.body).to include("https://www.chefsteps.com/classes/clummy")
      expect(response.body).to include("https://www.chefsteps.com/classes/zummy")
      expect(response.body).to include("https://www.chefsteps.com/frummy")
      expect(response.body).to_not include("https://chefsteps.com")
      expect(response.body).to_not include("https://www.chefsteps.com/hummy")
      expect(response.body).to_not include("https://www.chefsteps.com/activities/rummy")
      expect(response.body).to_not include("https://www.chefsteps.com/ingredients/mummy")
    end
  end
end
