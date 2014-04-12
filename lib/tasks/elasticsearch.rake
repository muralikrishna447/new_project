namespace :es do

  task :migrate_db => :environment do
    connect_to_source({params: {size: 100000, pretty: true}})
    connect_to_target
    source_data = @source.search index: 'bloom', body: { query: { match_all: { } } }
    source_comments = source_data['hits']['hits']
    bulk_body = []
    source_comments.each do |comment|
      puts 'THIS IS THE COMMENT'
      # index = comment['_index']
      index = 'xchefsteps'
      type = comment['_type']
      id = comment['_id']
      data = comment['_source']
      c = {
        'index' => {
          '_index' => index,
          '_type' => type,
          '_id' => id,
          'data' => data
        }
      }
      bulk_body << c
    end
    puts bulk_body
    puts bulk_body.length

    target_data = @target.bulk body: bulk_body
    puts target_data
  end

  def connect_to_source(options=nil)
    @source = Elasticsearch::Client.new host: 'http://d0d7d0e3f98196d4000.qbox.io', transport_options: options
  end

  def connect_to_target(options=nil)
    @target = Elasticsearch::Client.new host: 'http://ginkgo-5521397.us-east-1.bonsai.io', transport_options: options
    # @target = Elasticsearch::Client.new host: 'http://5b5d08a8de96bb85000.qbox.io', transport_options: options
  end

end