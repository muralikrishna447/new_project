# The purpose of this is to make sure that paid activities don't bunch up in gallery views
task :backdate_class_activities, [:class_slug] => [:environment]  do |t, args|
  $next_date = Time.new
  recursive_backdate(Assembly.find(args.class_slug))
end



def recursive_backdate(assembly)
  assembly.assembly_inclusions.each do |ai|
    if ai.includable_type == "Activity"
      ai.includable.published_at = $next_date
      ai.includable.save!
      puts "Backdated " + ai.includable.slug + " to " + $next_date.to_s
      $next_date = $next_date.advance(days: -5)

    elsif ai.includable_type == "Assembly"
      recursive_backdate(ai.includable)
    end
  end
end

