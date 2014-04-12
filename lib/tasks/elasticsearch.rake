namespace :es do

  task :migrate_db => :environment do
    # connect_to_source
    # connect_to_target
    # source_data = @source.get('/bloom/comment/_search?size=100000&pretty=true')
    # source_comments = JSON.parse(source_data.body)['hits']['hits']
    # bulk_body = []
    # source_comments.each do |comment|
    #   c = {'index' => comment}
    #   bulk_body << c
    # end
    # puts bulk_body
    # puts bulk_body.length
    # # target_data = @source.post('/_bulk', bulk_body)
    # puts target_data
    connect_to_source
    connect_to_target
    source_data = @source.search index: 'bloom', body: { query: { match_all: { } } }
    source_comments = source_data['hits']['hits']
    bulk_body = []
    source_comments.each do |comment|
      puts 'THIS IS THE COMMENT'
      index = comment['_index']
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

  def connect_to_source
    @source = Elasticsearch::Client.new host: 'http://d0d7d0e3f98196d4000.qbox.io/', transport_options: { params: {size: 100000, pretty: true}}
  end

  def connect_to_target
    @target = Elasticsearch::Client.new host: 'http://5b5d08a8de96bb85000.qbox.io/'
  end

end