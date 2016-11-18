aws_region = 'us-east-1'

bucket = 'chefsteps-rosti-development'
if Rails.env.staging?
  bucket = 'chefsteps-rosti-staging'
elsif Rails.env.production?
  bucket = 'chefsteps-rosti-production'
end

Fulfillment::RostiOrderExporter.configure(
  s3_region: aws_region,
  s3_bucket: bucket
)
Fulfillment::RostiShipmentImporter.configure(
  s3_region: aws_region,
  s3_bucket: bucket
)
