require 'spec_helper'

describe OrderSortQuestionContents do
  describe '#update' do
    describe 'basic update' do
      let(:question_params) do
        {
          question: "How do you cook a steak?",
          instructions: "Please arrange the scrambled pictures in the correct order.",
          solutions: "1,3,4, 7, 5|1,4,3,5,7"
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
      its(:solutions) {
        should == [
          { 'order_sort_image_ids' => [1, 3, 4, 7, 5] },
          { 'order_sort_image_ids' => [1, 4, 3, 5, 7] }
        ]
      }
    end

    it 'should handle blank solutions' do
      subject.update('order_sort_question' => { 'solutions' => '' })
      subject.solutions.should == []
    end

    it 'should handle 1 solution' do
      subject.update('order_sort_question' => { 'solutions' => '1,2,3' })
      subject.solutions.should == [
        { 'order_sort_image_ids' => [1, 2, 3] }
      ]
    end
  end

  describe '#correct' do
    subject do
      described_class.new(solutions: [
        { 'order_sort_image_ids' => [1, 2, 3] },
        { 'order_sort_image_ids' => [1, 3, 2] }
      ])
    end

    def answer_data(*answers)
      double(:answer_data, answers: answers)
    end

    it 'should return true for a correct answer' do
      subject.correct(answer_data(1, 2, 3)).should be_true
    end

    it 'should return true for an alternate correct answer' do
      subject.correct(answer_data(1, 3, 2)).should be_true
    end

    it 'should return false for an incorrect answer' do
      subject.correct(answer_data(2, 1, 3)).should be_false
    end
  end
end
