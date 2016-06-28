require 'csv'

task :initialize_first_published_at => :environment do

  # Initialize first_published_at with published_at, or an even earlier publish time if one can be found in the versions table
  Activity.all.each do |a|
    if a.published_at
      puts "Activity #{a.slug}"
      fpa = a.published_at

      if a.last_revision()
        last_rev_num = a.last_revision().revision
        versions = last_rev_num.downto(1).map do |r|
          rev = a.restore_revision(r)
          if rev.published_at && rev.published_at < fpa
            fpa = rev.published_at
          end
        end
      end

      if fpa
        # skip all validations and callbacks
        a.update_column(:first_published_at, fpa)
        if a.published_at != fpa
          puts "---- first_published_at: #{fpa}, published_at: #{a.published_at}"
        end
      end
    end
  end
end


