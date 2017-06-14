aws_region = 'us-east-1'

pending_bucket = 'chefsteps-fulfillment-development'
rosti_bucket = 'chefsteps-rosti-development'
fba_bucket = 'chefsteps-fulfillment-development'
shipments_queue_url = 'https://sqs.us-east-1.amazonaws.com/021963864089/fulfillment-rosti-shipments-development'
task_queue_prefix = 'https://sqs.us-east-1.amazonaws.com/021963864089/'
if Rails.env.staging?
  pending_bucket = 'chefsteps-fulfillment-staging'
  rosti_bucket = 'chefsteps-rosti-staging'
  fba_bucket = 'chefsteps-fulfillment-staging'
  shipments_queue_url = 'https://sqs.us-east-1.amazonaws.com/021963864089/fulfillment-rosti-shipments-staging'
elsif Rails.env.production?
  pending_bucket = 'chefsteps-fulfillment-production'
  rosti_bucket = 'chefsteps-rosti-production'
  fba_bucket = 'chefsteps-fulfillment-production'
  shipments_queue_url = ' https://sqs.us-east-1.amazonaws.com/021963864089/fulfillment-rosti-shipments-production'
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
Fulfillment::RostiShipmentPoller.configure(
  aws_region: aws_region,
  sqs_url: shipments_queue_url
)
Fulfillment::AwsQueuePoller.configure(
    aws_region: aws_region,
    task_queue_prefix: task_queue_prefix
)
Fulfillment::Fba.configure(
  mws_marketplace_id: 'ATVPDKIKX0DER', # Amazon US marketplace ID
  mws_merchant_id: ENV['MWS_MERCHANT_ID'],
  mws_access_key_id: ENV['MWS_ACCESS_KEY_ID'],
  mws_secret_access_key: ENV['MWS_SECRET_ACCESS_KEY']
)
Fulfillment::FbaOrderSubmitter.configure(
  s3_region: aws_region,
  s3_bucket: fba_bucket
)
