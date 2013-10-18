Fabricator(:comment) do
  user_id          1
  content          "MyText"
  commentable_id   1
  commentable_type "MyString"
end
