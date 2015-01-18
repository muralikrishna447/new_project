namespace :videos do
  task transcode: :environment do
    key = "AKIAIFVLJ74AFOXZWYFA"
    secret = "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"
    # s3 = AWS::S3::Client.new(
    #   access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    #   secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
    # transcoder = AWS::ElasticTranscoder::Client.new(
    #   access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    #   secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    #   region: 'us-east-1'
    #   )
    s3 = AWS::S3::Client.new(
      access_key_id: key,
      secret_access_key: secret)

    transcoder = AWS::ElasticTranscoder::Client.new(
      access_key_id: key,
      secret_access_key: secret,
      region: 'us-east-1'
      )

    keys = []
    response = s3.list_objects(bucket_name: 'chefsteps-videos')
    response.contents.each do |object|
      puts "#{object.key} => #{object.etag}"
      keys << object.key
    end
    puts "keys: #{keys}"

    # presets = transcoder.list_presets().presets
    # presets.each do |preset|
    #   puts "preset: #{preset}"
    # end
    keys.each do |key|
      key_split = key.split(".")

      # Transcode to mp4
      mp4_output_key = key_split[0] + "-480p.mp4"
      puts "output_key: #{mp4_output_key}"
      transcoder.create_job({
        pipeline_id: "1421398968195-mhvnn3",
        input: { key: key },
        output: {
          key: mp4_output_key,
          preset_id: "1351620000001-000020"
        }
      })
      puts "transcoded: #{key} to: #{mp4_output_key}"

      # Transcode to webm
      webm_output_key = key_split[0] + "-480p.webm"
      puts "output_key: #{webm_output_key}"
      transcoder.create_job({
        pipeline_id: "1421398968195-mhvnn3",
        input: { key: key },
        output: {
          key: webm_output_key,
          preset_id: "1421568826745-gsoi9m"
        }
      })
      puts "transcoded: #{key} to: #{webm_output_key}"
    end
  end
end