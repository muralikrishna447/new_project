class Presenter
  attr_accessor :model

  def initialize(model, *args)
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

  def self.wrapped_collection(collection, *args)
    collection.map do |model|
      new(model, *args).wrapped_attributes
    end
  end

  def self.present_collection(collection, *args)
    wrapped_collection(collection, *args).to_json
  end
end
