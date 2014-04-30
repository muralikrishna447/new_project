require 'elasticsearch/model'

Elasticsearch::Model.client = Elasticsearch::Client.new({host: '5b5d08a8de96bb85000.qbox.io:80', logs: true})