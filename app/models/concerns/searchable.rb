# See http://rubydoc.info/gems/elasticsearch-model/ for more info and examples

module Searchable
  extend ActiveSupport::Concern

  @elasticsearch_client = Elasticsearch::Client.new({host: '5b5d08a8de96bb85000.qbox.io:80', log: true})

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
    Elasticsearch::Model.client = Elasticsearch::Client.new({host: '5b5d08a8de96bb85000.qbox.io:80', log: true})

    settings index: { number_of_shards: 5, number_of_replicas: 1 }

    mapping do
      # ...
    end

    def self.search(query)
      self.__elasticsearch__.search query
    end

    def self.update_index
      self.__elasticsearch__.client.indices.delete index: self.index_name rescue nil
      self.__elasticsearch__.client.indices.create \
        index: self.index_name,
        body: { settings: self.settings.to_hash, mappings: self.mappings.to_hash }
    end
  end

  def self.search(query)
    @elasticsearch_client.search({q: query, size: 1000})
  end
end