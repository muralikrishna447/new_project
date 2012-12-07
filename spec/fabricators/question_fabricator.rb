Fabricator :multiple_choice_question do
  contents { Fabricate(:multiple_choice_question_contents) }
end

Fabricator :true_false_question, from: MultipleChoiceQuestion do
  contents { Fabricate(:true_false_question_contents) }
end
