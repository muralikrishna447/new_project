Fabricator :quiz_session do
  user { Fabricate(:user) }
  quiz { Fabricate(:quiz) }
end
