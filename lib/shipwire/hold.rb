module Shipwire
  class Hold
    # Shipwire's unique id for the hold
    attr_reader :id

    # The hold type, indicating the reason for the hold
    attr_reader :type

    # The hold subtype, indicating more specific reasons for the hold
    attr_reader :sub_type

    # The date the hold was cleared (as a string), or nil if the hold is active
    attr_reader :cleared_date

    def initialize(params = {})
      @id = params[:id]
      @type = params[:type]
      @sub_type = params[:sub_type]
      @cleared_date = params[:cleared_date]
    end

    def active?
      cleared_date.nil?
    end

    def self.array_from_hash(hold_array_hash)
      holds = []
      hold_array_hash.fetch('resource').fetch('items').each do |hold_hash|
        holds << from_hash(hold_hash.fetch('resource'))
      end
      holds
    end

    def ==(other)
      id == other.id &&
        type == other.type &&
        sub_type == other.sub_type &&
        cleared_date == other.cleared_date
    end

    private_class_method
    def self.from_hash(hold_hash)
      Shipwire::Hold.new(
        id: hold_hash.fetch('id'),
        type: hold_hash.fetch('type'),
        sub_type: hold_hash.fetch('subType'),
        cleared_date: hold_hash.fetch('clearedDate')
      )
    end
  end
end
