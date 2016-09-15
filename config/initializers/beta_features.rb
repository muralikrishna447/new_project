require 'beta_feature_service'
BetaFeatureService = BetaFeature::DynamoBetaFeatureService.new(
  Aws::DynamoDB::Client.new(region: 'us-east-1'),
  Rails.configuration.dynamodb.beta_features_table_config
)
