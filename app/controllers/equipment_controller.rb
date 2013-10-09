class EquipmentController < ApplicationController
  # respond_to :json

  has_scope :search_title

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
          result = apply_scopes(Equipment).where("title <>''").includes(:activities).order(sort_string).offset(params[:offset]).limit(params[:limit])
          if params[:detailed]
            render :json => result.as_json(include: {activities: {only: [:id, :title]}})
          else
            render :json => result.to_json
          end
        end
      end

      format.html do
        authorize! :update, Equipment unless Rails.env.angular?
        render
      end
    end
  end

  def update
    authorize! :update, Equipment unless Rails.env.angular?
    respond_to do |format|
      format.json do
        @equipment = Equipment.find(params[:id])
        begin
          @equipment.update_attributes(params[:equipment])
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
    authorize! :update, Equipment unless Rails.env.angular?
    @equipment = Equipment.find(params[:id])
    respond_to do |format|
      format.json do
        begin
          if (@equipment.activities.count) > 0
            raise "Can't delete equipment that is in use"
          else
            @equipment.destroy if false #unless Rails.env.angular?
            head :no_content
          end
        rescue Exception => e
          messages = [] || @equipment.errors.full_messages
          messages.push(e.message)
          puts $@
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

  def merge
    authorize! :update, Equipment unless Rails.env.angular?
    respond_to do |format|
      format.json do
        begin
          @result_equipment = Equipment.find(params[:id])
          @equipment = Equipment.find(params[:merge].split(','))
          puts "Merging " + @equipment.inspect
          puts "Into " + @result_equipment.inspect
          @result_equipment.merge(@equipment) unless Rails.env.angular?
          head :no_content
        rescue Exception => e
          messages = [] || @equipment.errors.full_messages
          messages.push(e.message)
          messages.push(e.backtrace)
          render json: { errors: messages}, status: 422
        end
      end
    end
  end

end
