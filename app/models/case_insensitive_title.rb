require 'active_support/concern'

module CaseInsensitiveTitle
  extend ActiveSupport::Concern

  included do
    before_save :capitalize_title
  end

  module ClassMethods
    def find_or_create_by_title(title)
      self.where('lower(title) = ?', title.downcase).first || self.create(title: title)
    end
  end

  private

  def capitalize_title
    self.title[0] = title[0].capitalize
  end
end
