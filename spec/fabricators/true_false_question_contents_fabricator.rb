Fabricator :true_false_question_contents, from: MultipleChoiceQuestionContents do
  question 'Is this true or false?'
  options(count: 2) do |attrs,i|
    {
      uid: "id-answer-#{i}",
      answer: i==1 ? 'True' : 'False',
      correct: (i==1)
    }
  end
end

