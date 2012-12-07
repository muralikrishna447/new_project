Fabricator :multiple_choice_answer do
  question { Fabricate(:multiple_choice_question) }
  user { Fabricate(:user) }
  contents { Fabricate(:multiple_choice_answer_contents) }
end
