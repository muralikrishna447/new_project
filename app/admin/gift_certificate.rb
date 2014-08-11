ActiveAdmin.register GiftCertificate do
  menu parent: 'Assemblies'
  remove_filter :user

  index do
    column "Course", :assembly
    column "Purchaser", :user
    column :price
    column :sales_tax
    column :redeemed
    column :recipient_email
    column :recipient_name
  end
end