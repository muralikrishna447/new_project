task :edit_report => :environment do
  edits = Event.where(trackable_type: "Ingredient", action: "edit").order("created_at desc").includes(:user).collect { |x| [x.trackable, x.user.email]}.uniq()
  edits.each do |x|
    if ! x[0].sub_activity_id
      puts "https://www.chefsteps.com/ingredients/#{x[0].slug} edited by #{x[1]}"
    end
  end
end