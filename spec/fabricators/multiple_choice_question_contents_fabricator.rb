Fabricator :multiple_choice_question_contents do
  question 'How much wood can a woodchuck chuck?'
  options(count: 2) {|attrs,i| {answer: "Answer #{i}", correct: (i % 2==0)}}
end
