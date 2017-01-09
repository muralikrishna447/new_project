ActiveAdmin.register Advertisement do
  form partial: 'form'

  index do
    column :matchname
    column :weight
    column :published
    column :add_referral_code
    column :title
    column :description
    column :campaign
    column :url
    default_actions
  end
end
