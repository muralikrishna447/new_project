gibbon = Gibbon::API.new(ENV['MAILCHIMP_API_KEY'])

namespace :interests do

  # Task to import exiting user emails into a Mailchimp list
  # Let's start with Sous Vide first and add the others if we decide to later
  # New users will be added when they complete the survey
  task :import_mailchimp => [:environment] do
    puts "Importing interests to Mailchimp"
    users = User.where("survey_results ? :key", key: "interests")
    users.each do |user|
      interests = user.survey_results['interests']
      if interests.include?('Sous Vide')
        begin
          puts "Importing user: #{user.email}"
          gibbon.lists.subscribe(
            id: '6024b56b7a',
            email: {email: user.email},
            merge_vars: {NAME: user.name, SOURCE: 'interests'},
            double_optin: false,
            send_welcome: false
          )
        rescue Exception => e
          puts "Error importing user: #{user.email}"
          puts "MailChimp error: #{e.message}"
        end
      end
    end
  end

end
