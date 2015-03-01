module ActsAsSanitized
  extend ActiveSupport::Concern

  def sanitize_input(*args)
    args.each do |field|
      self[field] = Sanitize.fragment(self[field], Sanitize::Config::RELAXED)
    end
  end
end

