
namespace :marketplace_features do
  require 'CSV'

  MARKETPLACE_GROUP = 'seattle_marketplace_customers'
  MARKETPLACE_FEATURE = 'seattle_marketplace_offers'
  DEV_GROUP = 'dev'
  BATCH_SIZE = 25

  def create_marketplace_group_features
    #create marketplace group/features, unless it already exists
    dynamo_client = Aws::DynamoDB::Client.new(region: 'us-east-1')
    table_config = Rails.configuration.dynamodb.beta_features_table_config
    [ {feature: MARKETPLACE_FEATURE, group: MARKETPLACE_GROUP},
      {feature: MARKETPLACE_FEATURE, group: DEV_GROUP}].each do |params|

      begin
        dynamo_client.put_item(
            item: {
                feature_name: params[:feature],
                group_name: params[:group],
                is_enabled: true
            },
            table_name: table_config[:group_features_table],
            condition_expression: 'attribute_not_exists(group_name) AND attribute_not_exists(feature_name)')
        puts "** Created #{params[:group]} / #{params[:feature]}"
      rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
        puts "** #{params[:group]} / #{params[:feature]} already exists, not creating"
      end
    end
  end

  def load_email_addresses(csv_file)
    #csv_file is an export from mailchimp
    #"Email Address","First Name","Last Name","Zip Code",Country,"Full Address","Number of Joule Cooks","Meat Referral Discount","Pick-up Areas",MEMBER_RATING,OPTIN_TIME,OPTIN_IP,CONFIRM_TIME,CONFIRM_IP,LATITUDE,LONGITUDE,GMTOFF,DSTOFF,TIMEZONE,CC,REGION,LAST_CHANGED,LEID,EUID,NOTES
    email_addrs = []
    CSV.foreach(csv_file) do |row|
      email_addrs << row[0]
    end
    email_addrs
  end

  def find_associations(group_name)
    associations = []
    dynamo_client = Aws::DynamoDB::Client.new(region: 'us-east-1')
    table_config = Rails.configuration.dynamodb.beta_features_table_config
    resp = dynamo_client.scan({
                                  scan_filter: {
                                      "group_name" => {
                                          attribute_value_list: [group_name],
                                          comparison_operator: "EQ",
                                      },
                                  },
                                  table_name: table_config[:group_associations_table]})
    while resp.items.length > 0
      associations << resp.items
      break if resp.last_evaluated_key.nil?
      resp = dynamo_client.scan({
                                    scan_filter: {
                                        "group_name" => {
                                            attribute_value_list: args.group_name,
                                            exclusive_start_key: resp.last_evaluated_key,
                                            comparison_operator: "EQ",
                                        },
                                    },
                                    table_name: table_config[:group_associations_table]
      })
    end
    associations.flatten
  end

  def create_batch_delete_associations(associations, group_name)
    #associations is a dynamo db items array
    #create a batch of hashes that can be deleted via batch_write
    batch = []
    this_batch = associations.slice!(0, BATCH_SIZE)
    this_batch.each do |assoc|
      batch << {
          delete_request: {
              key: {
                  user_id: assoc["user_id"],
                  group_name: group_name
              }
          }
      }
    end
    batch
  end

  task :add_marketplace_associations, [:csv_file] => :environment do |t,args|
    create_marketplace_group_features

    email_addrs = load_email_addresses(args.csv_file)
    dynamo_client = Aws::DynamoDB::Client.new(region: 'us-east-1')
    table_config = Rails.configuration.dynamodb.beta_features_table_config

    batch_items = []
    users = User.where(:email => email_addrs)
    users.each do |user|
      [MARKETPLACE_GROUP, DEV_GROUP].each do |group|

        batch_items << {
            put_request: {
                item: {
                  user_id: user.id,
                  group_name: group
                }
            }
        }
        if batch_items.length == BATCH_SIZE
          resp = dynamo_client.batch_write_item({
             request_items: {
                table_config[:group_associations_table] => batch_items
             },
             return_consumed_capacity: "INDEXES", # accepts INDEXES, TOTAL, NONE
             return_item_collection_metrics: "SIZE"
          })
          puts "[#{Time.now}] Added #{batch_items.length} items"
          batch_items.clear
        end
      end
    end

    if batch_items.length > 0
      resp = dynamo_client.batch_write_item({
                                                request_items: {
                                                    table_config[:group_associations_table] => batch_items
                                                },
                                                return_consumed_capacity: "INDEXES", # accepts INDEXES, TOTAL, NONE
                                                return_item_collection_metrics: "SIZE"
                                            })
      puts resp.inspect
      batch_items.clear
    end

  end


  task :delete_marketplace_associations, [:group_name] => :environment do |t,args|
    associations = find_associations(args.group_name)
    puts "#{associations.length} found"

    dynamo_client = Aws::DynamoDB::Client.new(region: 'us-east-1')
    table_config = Rails.configuration.dynamodb.beta_features_table_config

    #double loop is hokey, need to figure out why I'm not getting all items with the one loop
    while associations.length > 0
      while associations.length > 0
        batch_to_delete = create_batch_delete_associations(associations, args.group_name)
        dynamo_client.batch_write_item({
               request_items: {
                   table_config[:group_associations_table] => batch_to_delete
               },
               return_consumed_capacity: "INDEXES", # accepts INDEXES, TOTAL, NONE
               return_item_collection_metrics: "SIZE" # accepts SIZE, NONE
        })
        puts "[#{Time.now}] Deleted #{batch_to_delete.length} items"
      end
      associations = find_associations(args.group_name)
    end
  end
end


