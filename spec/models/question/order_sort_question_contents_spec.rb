require 'spec_helper'

describe OrderSortQuestionContents do
  describe '#update' do
    let(:question_params) do
      {
        question: "How do you cook a steak?",
        instructions: "Please arrange the scrambled pictures in the correct order.",
        solutions: [
          {
            order_sort_image_ids: [1, 3, 4, 7, 6]
          },
          {
            order_sort_image_ids: [1, 3, 7, 4, 6]
          }
        ]
      }.with_indifferent_access
    end

    let(:params) do
      { order_sort_question: question_params, foo: 'bar' }.with_indifferent_access
    end

    before do
      subject.update(params)
    end

    its(:question) { should == 'How do you cook a steak?' }
    its(:instructions) { should == "Please arrange the scrambled pictures in the correct order." }
    its(:solutions) { should have(2).things }
  end
end
