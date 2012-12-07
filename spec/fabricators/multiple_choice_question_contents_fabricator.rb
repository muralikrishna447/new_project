Fabricator :multiple_choice_question_contents do
  question 'How much wood can a woodchuck chuck?'
  options(count: 2) do |attrs,i|
    {
      uid: "id-answer-#{i}",
      answer: "Answer #{i==1?'Correct':'Incorrect'}",
      correct: (i==1)
    }
  end
end
