module PublishableModel
  extend ActiveSupport::Concern

  included do
    scope :published, -> { where(published: true) }
    scope :unpublished, -> {  where(published: false) }
  end


  module ClassMethods
    def find_published(id, token=nil, admin=false)
      scope = (PrivateToken.valid?(token) || admin) ? scoped : published
      scope.friendly.find(id)
    end
  end
end

