Fabricator :multiple_choice_answer do
  question { Fabricate(:multiple_choice_question) }
  user { Fabricate(:user) }
  contents { {answer: 'true'} }
end
