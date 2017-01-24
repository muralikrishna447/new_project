aws_region = 'us-east-1'

pending_bucket = 'chefsteps-fulfillment-development'
rosti_bucket = 'chefsteps-rosti-development'
if Rails.env.staging?
  pending_bucket = 'chefsteps-fulfillment-staging'
  rosti_bucket = 'chefsteps-rosti-staging'
elsif Rails.env.production?
  pending_bucket = 'chefsteps-fulfillment-production'
  rosti_bucket = 'chefsteps-rosti-production'
end

Fulfillment::PendingOrderExporter.configure(
  s3_region: aws_region,
  s3_bucket: pending_bucket
)
Fulfillment::RostiOrderSubmitter.configure(
  s3_region: aws_region,
  s3_bucket: rosti_bucket
)
Fulfillment::RostiShipmentImporter.configure(
  s3_region: aws_region,
  s3_bucket: rosti_bucket
)

shipments_queue_url = 'https://sqs.us-east-1.amazonaws.com/021963864089/fulfillment-rosti-shipments-development'
Fulfillment::RostiShipmentPoller.configure(
  aws_region: aws_region,
  sqs_url: shipments_queue_url
)
