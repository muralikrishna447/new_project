ActiveAdmin.register PremiumGiftCertificate do
  remove_filter :user
  includes :user

  scope("Redeemed") { |scope| scope.where(redeemed: true) }
  scope("Not Redeemed") { |scope| scope.where(redeemed: false) }

  index do
    column "Purchaser", :user
    column :price do |g|
       g.price / 100.0
    end
    column :sales_tax do |g|
      g.sales_tax / 100.0
    end
    column :redeemed
  end
end