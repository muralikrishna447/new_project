class Presenter
  attr_accessor :model

  def initialize(model)
    @model = model
  end

  def present
    wrapped_attributes.to_json
  end

  # override this in subclasses
  def attributes
    {}
  end

  def wrapped_attributes
    HashWithIndifferentAccess.new(attributes)
  end

  def self.present_collection(collection)
    collection.map do |model|
      new(model).wrapped_attributes
    end.to_json
  end
end
