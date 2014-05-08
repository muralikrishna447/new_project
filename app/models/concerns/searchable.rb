# See http://rubydoc.info/gems/elasticsearch-model/ for more info and examples

module Searchable
  extend ActiveSupport::Concern

  @elasticsearch_client = Elasticsearch::Client.new({host: '5b5d08a8de96bb85000.qbox.io:80', log: true})

  included do
    include Elasticsearch::Model
    Elasticsearch::Model.client = Elasticsearch::Client.new({host: '5b5d08a8de96bb85000.qbox.io:80', log: true})

    def self.search(query)
      self.__elasticsearch__.search query
    end

    # Update settings to change the number of shards and replicas. 
    # Then run Activity.update_settings and Activity.import to reindex Activities
    settings index: { number_of_shards: 5, number_of_replicas: 1 }

    def self.update_settings
      self.__elasticsearch__.client.indices.delete index: self.index_name rescue nil
      self.__elasticsearch__.client.indices.create \
        index: self.index_name,
        body: { settings: self.settings.to_hash, mappings: self.mappings.to_hash }
    end
  end

  def self.search(query)
    response = @elasticsearch_client.search q: query, size: 100
    response['hits']['hits']
  end
end