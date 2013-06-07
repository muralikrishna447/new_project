ActiveAdmin.register Inclusion do

  form do |f|
    f.inputs "Details" do
      f.input :title, hint: 'The value in this field will show up in the course syllabus. Leave this blank to use the activity title instead.'
    end
    f.actions
  end

  controller do
    def update
      @inclusion = Inclusion.find(params[:id])
      if @inclusion.update_attributes(params[:inclusion])
        redirect_to edit_admin_course_path(@inclusion.course)
      else
        render action: 'edit'
      end
    end
  end
end