ActiveAdmin.register Copy do

  form do |f|
    f.inputs "Copy Details" do
      f.input :location
      f.input :copy, label: "Copy (Markdown or HTML)"
      f.buttons
    end
  end

end

