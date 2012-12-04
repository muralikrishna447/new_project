module SerializeableContents
  extend ActiveSupport::Concern

  included do
    after_initialize :init_contents
  end

  def update_contents(params)
    self.contents.update(params)
  end

  def contents_json(admin)
    self.contents.to_json(admin)
  end

  private
  def init_contents
    return if persisted?
    self.contents = contents_class.new({}) if self.contents.blank?
  end

  def contents_class
    (self.class.name.to_s + 'Contents').constantize
  end
end
