ActiveAdmin.register Enrollment do
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

end