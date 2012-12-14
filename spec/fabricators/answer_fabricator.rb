Fabricator :multiple_choice_answer do
  question { Fabricate(:multiple_choice_question) }
  user { Fabricate(:user) }
  contents { Fabricate(:multiple_choice_answer_contents) }
end

Fabricator :true_false_answer, from: MultipleChoiceAnswer do
  question { Fabricate(:true_false_question) }
  user { Fabricate(:user) }
  contents { Fabricate(:true_false_answer_contents) }
end

Fabricator :box_sort_answer, from: BoxSortAnswer do
  question { Fabricate(:box_sort_question) }
  user { Fabricate(:user) }
  contents { Fabricate(:box_sort_answer_contents) }
end
