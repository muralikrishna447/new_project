# See http://rubydoc.info/gems/elasticsearch-model/ for more info and examples

module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    Elasticsearch::Model.client = Elasticsearch::Client.new({host: '5b5d08a8de96bb85000.qbox.io:80', log: true})

    mapping do
      # ...
    end

    def self.search(query)
      self.__elasticsearch__.search query
    end
  end
end