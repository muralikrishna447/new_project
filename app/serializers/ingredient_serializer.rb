class IngredientSerializer < ActiveModel::Serializer
  attributes :id, :title, :product_url, :created_at, :updated_at, :for_sale, :sub_activity_id, :density
  has_many :activities
end