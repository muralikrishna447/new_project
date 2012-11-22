class Presenter
  attr_accessor :model

  def initialize(model)
    @model = model
  end

  def present
    HashWithIndifferentAccess.new(attributes).to_json
  end

  # override this in subclasses
  def attributes
    {}
  end
end
