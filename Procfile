web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: env TERM_CHILD=1 QUEUE=* bundle exec rake resque:work
giftworker:  env TERM_CHILD=1 QUEUE=ChargeBeeGiftProcessor bundle exec rake resque:work