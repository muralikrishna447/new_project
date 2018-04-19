require 'spec_helper'

manifest = JSON.parse(File.read('spec/models/fixtures/manifest.json'))

describe GuideActivity do

  before :each do
    WebMock.stub_request(:post, "https://www.filestackapi.com/api/store/S3?key=BOGUS_FILEPICKER_KEY")
      .to_return(:status => 200, :body => '{"url": "FAKEIMAGE.JPG"}', :headers => {})
  end

  context 'create_or_update_from_guide' do
    it 'creates new activity with expected contents' do
      guide = manifest['guide'].find {|g| g['slug'] == 'creme-brulee-guide'}
      ga = GuideActivity::create_or_update_from_guide(manifest, guide, false)
      expect(ga).not_to be_nil
      expect(ga.guide_id).to eq(guide['id'])
      expect(ga.guide_title).to eq(guide['title'])

      # Prior to rails 3.2.19 - Ampersands and chars not previously encoded as \u0026 in url query strings
      # expect(ga.guide_digest).to eq('ff2093e8b524df918cf2e38cd1b460c0')

      expect(ga.guide_digest).to eq('ef36da81cc36122b13de0203a3cf5f68')

      a = Api::ActivitySerializer.new(ga.activity).serializable_object
      expect(a[:title]).to eq(guide['title'])
      expect(a[:url]).to include('cracklin')
      expect(a[:description]).to include("velvety-smooth texture")
      expect(a[:image]).to eq('FAKEIMAGE.JPG')
      expect(a[:tagList]).to include('sous vide')
      expect(a[:tagList]).to include('guide')
      expect(a[:tagList]).to include('convertedguide')
      expect(a[:tagList]).to include('Rich and Creamy Custards')
      expect(a[:chefstepsGenerated]).to eq(true)
      expect(a[:heroImage]).to eq('FAKEIMAGE.JPG')
      expect(a[:premium]).to eq(false)
      expect(a[:ingredients].length).to eq(4)
      expect(a[:ingredients][0][:title]).to eq('Egg yolks')
      expect(a[:ingredients][0][:quantity]).to eq(160.0)
      expect(a[:ingredients][0][:unit]).to eq('g')
      expect(a[:ingredients][0][:note]).to eq('about 11')
      expect(a[:equipment].length).to eq(7)
      expect(a[:equipment][0][:optional]).to eq(false)
      expect(a[:equipment][0][:equipment][:title]).to eq('Sous vide setup')
      expect(a[:equipment][1][:equipment][:title]).to eq('Digital scale')
      expect(a[:steps].length).to eq(10)
      expect(a[:steps][0][:directions]).to include('[sendToMessenger')
      expect(a[:steps][1][:title]).to include('Separate')
      expect(a[:steps][1][:directions]).to include('Crack shell')
      expect(a[:steps][1][:image]).to eq('FAKEIMAGE.JPG')
    end

    it 'doesn\'t do any work on guides with no hero image' do
      guide = manifest['guide'].find {|g| g['slug'] == 'creme-brulee-guide'}
      guide = guide.dup
      guide['landscapeImage'] = guide['image'] = guide['thumbnail'] = nil
      expect(GuideActivity::create_or_update_from_guide(manifest, guide, false)).to be_nil
    end

    it 'doesn\'t do any work if GuideActivity exists with autoupdate off' do
      guide = manifest['guide'].find {|g| g['slug'] == 'creme-brulee-guide'}
      ga = GuideActivity::create_or_update_from_guide(manifest, guide, false)
      ga.autoupdate = false
      ga.save!

      expect(GuideActivity::create_or_update_from_guide(manifest, guide, false)).to be_nil
    end

    it 'doesn\'t do any work if GuideActivity with same digest already exists' do
      guide = manifest['guide'].find {|g| g['slug'] == 'creme-brulee-guide'}
      expect(GuideActivity::create_or_update_from_guide(manifest, guide, false)).to_not be_nil
      expect(GuideActivity::create_or_update_from_guide(manifest, guide, false)).to be_nil
    end

    it 'ignores digest check if force is true' do
      guide = manifest['guide'].find {|g| g['slug'] == 'creme-brulee-guide'}
      expect(GuideActivity::create_or_update_from_guide(manifest, guide, false)).to_not be_nil
      expect(GuideActivity::create_or_update_from_guide(manifest, guide, true)).to_not be_nil
    end

    it 'reuses and updates existing Activity and GuideActivity if one exists but digest has changed' do
      guide = manifest['guide'].find {|g| g['slug'] == 'creme-brulee-guide'}
      ga1 = GuideActivity::create_or_update_from_guide(manifest, guide, false)

      guide = guide.dup
      guide['description'] = 'New description'
      ga2 = GuideActivity::create_or_update_from_guide(manifest, guide, false)

      expect(ga2).to_not be_nil
      expect(ga2.guide_digest).to_not eq(ga1.guide_digest)
      expect(ga2.id).to eq(ga1.id)
      expect(ga2.activity_id).to eq(ga1.activity_id)
      expect(ga2.activity.description).to include('New description')
    end
  end

  context 'parse_ingredient' do

    def expect_ingredient(line, quantity, unit, title, note)
      expect(GuideActivity::parse_ingredient(line))
        .to eq({title: title, quantity: quantity, unit: unit, note: note})
    end

    it 'handles case with unitless number' do
      expect_ingredient('Sweet onion, 1 large', '1', 'ea', 'Sweet onion', 'large')
    end

    it 'handles full case with parenthesized grams' do
      expect_ingredient('Egg yolks, 6 oz (160 g), about 11', '160', 'g', 'Egg yolks', 'about 11')
    end

    it 'handles naked a/n' do
      expect_ingredient('Cooking oil, a/n', nil, 'a/n', 'Cooking oil', '')
    end

    it 'handles (optional)' do
      expect_ingredient('Black pepper, a/n (optional)', nil, 'a/n', 'Black pepper', '(optional)')
    end

    it 'handles note with no quantity' do
      expect_ingredient('Pine nuts, about 30', nil, 'a/n', 'Pine nuts', 'about 30')
    end

    it 'handles extra commas mania' do
      # These are bad and unusual cases, just make sure we don't lose any info even if a lot ends up in the note
      expect_ingredient('Stock, such as chicken, beef, or vegetable, 6 oz (170 g)', nil, 'a/n', 'Stock', 'such as chicken, beef, or vegetable, 6 oz (170 g)')
      expect_ingredient('Dark chocolate, 70%, 6 oz (175 g)', nil, 'a/n', 'Dark chocolate', '70%, 6 oz (175 g)')
    end
  end
end