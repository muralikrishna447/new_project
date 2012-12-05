require 'spec_helper'

describe ImagePresenter, "#present" do
  let(:image) { Fabricate.build(:quiz_image) }
  let(:image_presenter) { ImagePresenter.new(image) }

  subject { image_presenter.attributes }

  it "serializes valid keys" do
    subject.keys.should =~ [:id, :filename, :caption, :url]
  end
end

