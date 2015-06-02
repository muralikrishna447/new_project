gibbon = Gibbon::API.new(ENV['MAILCHIMP_API_KEY'])

namespace :interests do

  # Task to import exiting user emails into a Mailchimp list
  # Let's start with Sous Vide first and add the others if we decide to later
  # New users will be added when they complete the survey
  task :import_mailchimp => [:environment] do
    puts "Importing interests to Mailchimp"
    users = User.where("survey_results ? :key", key: "interests")

    # puts gibbon.lists.interest_groupings({id: 'a61ebdcaa6'})
    users.each do |user|
      interests = user.survey_results['interests']
      interests = interests.reject{ |name| name.blank? } if interests.kind_of?(Array)

      merge_vars = {
        groupings: [
          {
            id: '8061',
            groups: interests
          }
        ]
      }

      begin
        puts "Adding user: #{user.email} to interest groups"
        gibbon.lists.update_member(
          id: 'a61ebdcaa6',
          email: { email: user.email },
          merge_vars: merge_vars
        )
      rescue Exception => e
        puts "Error adding user: #{user.email}"
        puts "Error message: #{e.message}"
      end
    end
  end

end
