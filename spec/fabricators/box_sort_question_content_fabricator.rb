Fabricator :box_sort_question_contents do
  instructions 'Sort the images'
  options(count: 2) do |attrs,i|
    {
      uid: "id-option-#{i}",
      text: "I #{i==1?'Remember':"Don't Remember"}"
    }
  end
end
