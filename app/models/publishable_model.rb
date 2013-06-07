module PublishableModel
  extend ActiveSupport::Concern

  included do
    scope :published, where(published: true)
    attr_accessible :published
  end


  module ClassMethods
    def find_published(id, token=nil, admin=false)
      scope = (PrivateToken.valid?(token) || admin) ? scoped : published
      scope.find(id)
    end
  end
end

