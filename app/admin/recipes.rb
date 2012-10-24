ActiveAdmin.register Recipe do

  show do |recipe|
    render "show", recipe: recipe
  end

  form partial: 'form'
end

