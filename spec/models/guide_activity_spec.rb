require 'spec_helper'

manifest = JSON.parse(File.read('spec/models/fixtures/manifest.json'))

describe GuideActivity do

  before :each do
    WebMock.stub_request(:post, "https://www.filestackapi.com/api/store/S3?key=BOGUS_FILEPICKER_KEY")
      .to_return(:status => 200, :body => '{"url": "FAKEIMAGE.JPG"}', :headers => {})
  end

#TODO
# tag not inlcuding all-guides
# http://localhost:3000/activities/basic-chicken-breast ingredients messed up

  context 'create_or_update_from_guide' do
    it 'creates new activity' do
      guide = manifest['guide'].find {|g| g['slug'] == 'creme-brulee-guide'}
      ga = GuideActivity::create_or_update_from_guide(manifest, guide, false)
      expect(ga).not_to be_nil
      expect(ga.guide_id).to eq(guide['id'])
      expect(ga.guide_title).to eq(guide['title'])
      a = Api::ActivitySerializer.new(ga.activity).serializable_object
      expect(a[:title]).to eq(guide['title'])
      expect(a[:url]).to include('cracklin')
      expect(a[:description]).to include("velvety-smooth texture")
      expect(a[:description]).to include("[sendToMessenger")
      expect(a[:image]).to eq('FAKEIMAGE.JPG')
      expect(a[:tagList]).to include('sous vide')
      expect(a[:tagList]).to include('guide')
      expect(a[:tagList]).to include('convertedguide')
      expect(a[:chefstepsGenerated]).to eq(true)
      expect(a[:heroImage]).to eq('FAKEIMAGE.JPG')
      expect(a[:premium]).to eq(false)
      expect(a[:ingredients].length).to eq(4)
      expect(a[:ingredients][0][:title]).to eq('Egg yolks')
      expect(a[:ingredients][0][:quantity]).to eq(160.0)
      expect(a[:ingredients][0][:unit]).to eq('g')
      expect(a[:ingredients][0][:note]).to eq('about 11')
      expect(a[:equipment].length).to eq(6)
      expect(a[:equipment][0][:optional]).to eq(false)
      expect(a[:equipment][0][:equipment][:title]).to eq('Digital scale')
      expect(a[:steps].length).to eq(10)
      expect(a[:steps][0][:title]).to include('Separate')
      expect(a[:steps][0][:directions]).to include('Crack shell')
      expect(a[:steps][0][:image]).to eq('FAKEIMAGE.JPG')
    end
  end
end
