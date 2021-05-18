ActiveAdmin.register SuggestedRecipe do
  actions :index

  config.batch_actions = false


  menu parent: 'More'

  filter :name
  filter :created_at
  filter :updated_at

  controller do
    def scoped_collection
      super.includes(:users)
    end
  end


  index do
    id_column
    column :name
    column(:users_count, sortable: 'count(users.*) as user_count') { |b| b.users.count }
  end

end
