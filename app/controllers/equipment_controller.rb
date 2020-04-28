class EquipmentController < ApplicationController
  # respond_to :json
  has_scope :search_title do |controller, scope, value|
    controller.params[:exact_match] == "true" ? scope.exact_search(value) : scope.search_title(value)
  end

  # This is the old equipment controller
  # def index
  #   result = Equipment.where('title iLIKE ?', '%' + params[:q] + '%').all
  #   respond_with result
  # end

  def index
    respond_to do |format|
      format.json do
        if params[:q] # Check for typeahead
          result = Equipment.where('title iLIKE ?', '%' + params[:q] + '%').all
          render :json => result
        else
          sort_string = (params[:sort] || "title") + " " + (params[:dir] || "ASC").upcase
          # result = Equipment.where("title <>''").includes(:activities).order(sort_string).offset(params[:offset]).limit(params[:limit])
          # result = (params[:exact_match]=="true") ? result.where("title = ?", params[:search_title]) : result.where("title iLIKE ?", "%#{params[:search_title]}%")
          result = apply_scopes(Equipment).where("title <>''").includes(:activities).order(sort_string).offset(params[:offset]).limit(params[:limit])
          if params[:detailed]
            render :json => result.as_json(include: {activities: {only: [:id, :title]}})
          else
            render :json => result.to_json
          end
        end
      end

      format.html do
        authorize! :update, Equipment
        render
      end
    end
  end

  def update
    authorize! :update, Equipment
    respond_to do |format|
      format.json do
        @equipment = Equipment.find(params[:id])
        begin
          @equipment.update_attributes(equipment_params)
          head :no_content
        rescue Exception => e
          messages = [] || @equipment.errors.full_messages
          messages.push(e.message)
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

  def destroy
    authorize! :update, Equipment
    @equipment = Equipment.find(params[:id])
    respond_to do |format|
      format.json do
        begin
          if (@equipment.activities.count) > 0
            raise "Can't delete equipment that is in use"
          else
            @equipment.destroy
            head :no_content
          end
        rescue Exception => e
          messages = [] || @equipment.errors.full_messages
          messages.push(e.message)
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

  def merge
    authorize! :update, Equipment
    respond_to do |format|
      format.json do
        begin
          @result_equipment = Equipment.find(params[:id])
          @equipment = Equipment.find(params[:merge].split(','))
          puts "Merging " + @equipment.inspect
          puts "Into " + @result_equipment.inspect
          @result_equipment.merge(@equipment)
          head :no_content
        rescue ActiveRecord::RecordNotUnique => e
          messages = [] || @equipment.errors.full_messages
          messages.push("You cannot merge equipment that is used on the same activity")
          render json: { errors: messages}, status: 422
        rescue Exception => e
          messages = [] || @equipment.errors.full_messages
          messages.push(e.message)
          # messages.push(e.backtrace) # For debuggin only
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

  private


  def equipment_params
    params.require(:equipment).permit(:title, :product_url)
  end

end
