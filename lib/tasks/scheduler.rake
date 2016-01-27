task :edit_report => :environment do
  msg = "Ingredient edits since #{1.days.ago.in_time_zone('Pacific Time (US & Canada)')}\n"
  edits = Event.where(trackable_type: "Ingredient", action: "edit").where("created_at > ?", 1.days.ago).order("created_at desc").includes(:user).collect { |x| [x.trackable, x.user]}.uniq()
  edits.reject! { |x| x[0].sub_activity_id }
  edits = edits.group_by { |x| x[1]}
  edits.each do |k, v|

    msg += "\n\n--- #{k.name} (#{k.email}) ---"
    v.each do |s|
      msg += "\nhttps://www.chefsteps.com/ingredients/#{s[0].slug}"
    end
  
  end
  GenericMailer.recipient_email("all@chefsteps.com", "CS AUTOMATED: Ingredient edit report", msg).deliver
end