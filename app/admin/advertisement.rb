ActiveAdmin.register Advertisement do
  permit_params :matchname, :published, :image, :title, :description, :button_title, :url, :campaign, :weight, :add_referral_code

  form partial: 'form'

  index do
    column :matchname
    column :weight
    column :published
    column :add_referral_code
    column :title
    column :description
    column :campaign
    column :url do |ad|
      truncate(ad.url, omision: "...", length: 100)
    end
    actions
  end
end
