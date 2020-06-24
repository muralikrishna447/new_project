class AddClassPremiumFlag < ActiveRecord::Migration[5.2]
  def up
    add_column :assemblies, :premium, :boolean, default: false
    Assembly.all.each do |a|
      if a.price && a.price > 0
        a.premium = true
        puts "Premium: #{a.slug}"
      end
      a.save
    end
  end

  def down
    remove_column :assemblies, :premium
  end
end
