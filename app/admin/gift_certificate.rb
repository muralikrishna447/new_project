ActiveAdmin.register PremiumGiftCertificate do
  remove_filter :user

  index do
    column "Purchaser", :user
    column :price
    column :sales_tax
    column :redeemed
  end
end