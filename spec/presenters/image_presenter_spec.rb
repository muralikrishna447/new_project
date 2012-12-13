require 'spec_helper'

describe ImagePresenter, "#present" do
  let(:image) { Fabricate.build(:image) }
  let(:image_presenter) { ImagePresenter.new(image) }

  subject { image_presenter.attributes }

  it "serializes valid keys" do
    subject.keys.should =~ [:id, :filename, :caption, :url]
  end

  context "BoxSortImage" do
    let(:image) { Fabricate.build(:box_sort_image) }

    it "extends attributes to include box sort attributes" do
      subject.keys.should include :key_image
      subject.keys.should include :key_explanation
    end
  end
end

