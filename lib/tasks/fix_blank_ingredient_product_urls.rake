task :fix_blank_ingredient_product_urls => :environment do
  Ingredient.all.each do |i|
    if i.product_url == ""
      i.product_url = nil
      i.save!
    end
  end
end