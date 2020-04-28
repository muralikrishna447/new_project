ActiveAdmin.register Enrollment do
  includes :user
  filter :enrollable_id, collection: proc {  Assembly.pubbed_courses }, as: :select
  menu parent: 'Assemblies'

  form :partial => "form"

  collection_action :free, :method => :post do
    assembly = Assembly.find(params[:assembly_id])
    user = User.where(email: params[:email]).first
    if user
      if user.enrolled?(assembly)
        flash[:error] = "User with email: #{user.email} is already enrolled into #{assembly.title}"
      else
        enrollment = Enrollment.new
        enrollment.user = user
        enrollment.enrollable = assembly
        if enrollment.save
          flash[:notice] = "Enrollment created for user with email: #{user.email}"
        end
      end
    else
      flash[:error] = "Could not find user with email: #{params[:email]}."
    end
    redirect_to :action => :new
  end

  index do
    column :id
    column :created_at
    column 'User Name' do |enrollment|
      link_to enrollment.user.name, user_profile_path(enrollment.user)
    end
    column 'Email' do |enrollment|
      enrollment.user.email
    end
    column 'Title' do |enrollment|
      enrollment.enrollable.title
    end
  end

  csv do
    column :id
    column :created_at
    column 'User Name' do |enrollment|
      enrollment.user.name
    end
    column 'Email' do |enrollment|
      enrollment.user.email
    end
    column 'Class' do |enrollment|
      enrollment.enrollable.slug
    end
  end
 

end