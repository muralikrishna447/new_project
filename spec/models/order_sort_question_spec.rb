require 'spec_helper'

describe OrderSortQuestion do
  describe '#update_from_params' do
    let(:params) do
      {
        'order_sort_question' => {
          'question' => 'How do you cook?',
          'instructions' => 'Arrange the photos in order.',
          'solutions' => [
            { 'order_sort_image_ids' => [1, 2, 3, 4] }
          ]
        }
      }
    end

    it 'should serialize correctly' do
      subject.update_from_params(params)
      subject.contents.question.should == 'How do you cook?'
    end

    it 'should save' do
      subject.update_from_params(params)
      subject.should_not be_new_record
    end
  end
end
