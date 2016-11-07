aws_region = 'us-east-1'

if Rails.env.development?
  Fulfillment::RostiOrderExporter.configure(
    s3_region: aws_region,
    s3_bucket: 'chefsteps-rosti-development'
  )
elsif Rails.env.staging?
  Fulfillment::RostiOrderExporter.configure(
    s3_region: aws_region,
    s3_bucket: 'chefsteps-rosti-staging'
  )
elsif Rails.env.production?
  Fulfillment::RostiOrderExporter.configure(
    s3_region: aws_region,
    s3_bucket: 'chefsteps-rosti-production'
  )
end
