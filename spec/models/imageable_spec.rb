describe Imageable, '#update_image' do
  let(:imageable) { Fabricate(:multiple_choice_question) }
  let(:image_params) { { url: 'www.foo.bar', filename: 'some file name', key: '123', size: 5005 } }

  subject { imageable.update_image(image_params) }

  it 'saves' do
    subject.should be_persisted
  end

  it "creates an image if none exist" do
    subject
    imageable.image.filename.should == 'some file name'
    imageable.image.url.should == 'www.foo.bar'
  end

  it "does nothing if empty hash" do
    imageable.update_image({})
    imageable.reload
    imageable.image.should_not be
  end

  context "with an existing image" do
    let(:image) { Fabricate.build(:image) }

    before do
      imageable.image = image
    end

    it "updates the image" do
      subject
      imageable.image.filename.should == 'some file name'
      imageable.image.url.should == 'www.foo.bar'
    end

    it "destroys the image if empty hash" do
      imageable.update_image({})
      imageable.reload
      imageable.image.should_not be
    end
  end
end

