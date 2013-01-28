require 'spec_helper'

describe OrderSortImage do
  describe '#update_from_params' do
    let(:params) do
      { caption: 'caption', filename: 'filename', url: 'url' }
    end

    it "should create an Image if one doesn't exist" do
      expect {
        subject.update_from_params(params)
      }.to change(subject, :image).from(nil)
    end

    it 'should set the caption, filename, and url on the Image' do
      subject.update_from_params(params)

      subject.image.caption.should == 'caption'
      subject.image.filename.should == 'filename'
      subject.image.url.should == 'url'
    end
  end
end
