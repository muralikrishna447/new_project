task :edit_report => :environment do
  edits = Event.where(trackable_type: "Ingredient", action: "edit").where("updated_at > ?", 1.days.ago).order("created_at desc").includes(:user).collect { |x| [x.trackable, x.user]}.uniq()
  edits.reject! { |x| x[0].sub_activity_id }
  edits = edits.group_by { |x| x[1]}
  edits.each do |k, v|
    puts "----------------------"
    puts "#{k.name} (#{k.email}) edited: "
    v.each do |s|
      puts "http://chefsteps.com/ingredients/#{s[0].slug}"
    end
    puts
  end
end