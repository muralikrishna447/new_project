module Api
  module V0
    class IngredientsController < ApplicationController

      def index
        per = params[:per] ? params[:per] : 12
        @ingredients = Ingredient.page(params[:page]).per(per)
        render json: @ingredients, each_serializer: Api::IngredientIndexSerializer, except: :productUrl
      end

      def show
        @ingredient = Ingredient.find(params[:id])
        render json: @ingredient, serializer: Api::IngredientSerializer
      end
    end
  end
end