namespace :classes do
  task :segment, [:segment_name] => :environment do |t, args|
    segment_name = args[:segment_name]
    case segment_name
    when 'sv_beyond_the_basics'
      puts 'Users enrolled in Cooking Sous Vide: Beyond the Basics'
      a = Assembly.find 'cooking-sous-vide-beyond-the-basics'
      enrollments = a.enrollments
      emails = enrollments.map{|e| e.user.email}
      puts emails.join(',')
    when 'sv_getting_started_not_in_beyond_the_basics'
      puts 'Users enrolled in Cooking Sous Vide: Getting Started but not in Cooking Sous Vide: Beyond the Basics'
      a = Assembly.find 'cooking-sous-vide-beyond-the-basics'
      b = Assembly.find 'cooking-sous-vide-getting-started'

      a_enrollments = a.enrollments
      b_enrollments = b.enrollments

      a_emails = a_enrollments.map{|e| e.user.email}
      b_emails = []
      b_enrollments.each do |enrollment|
        if enrollment.user
          b_emails << enrollment.user.email
        end
      end

      puts "Beyond the Basics Enrollments: #{a_emails.count}"
      puts "Getting Started Enrollments: #{b_emails.count}"
      c = b_emails - a_emails
      puts c.join(',')
      # puts "Include?"
      # puts a_emails.include?(c.first)
      puts "Count: #{c.count}"
    when 'both'
      puts 'Users enrolled in both classes'
      a = Assembly.find 'cooking-sous-vide-beyond-the-basics'
      b = Assembly.find 'cooking-sous-vide-getting-started'
      a_enrollments = a.enrollments
      b_enrollments = b.enrollments

      a_emails = a_enrollments.map{|e| e.user.email}
      b_emails = []
      b_enrollments.each do |enrollment|
        if enrollment.user
          b_emails << enrollment.user.email
        end
      end

      puts "Beyond the Basics Enrollments: #{a_emails.count}"
      puts "Getting Started Enrollments: #{b_emails.count}"
      c = b_emails + a_emails
      puts c.join(',')
      puts "Count: #{c.count}"
    else

    end
  end
end