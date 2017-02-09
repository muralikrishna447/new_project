require 'spec_helper'

describe Fulfillment::RostiShipmentPoller do
  let(:s3_bucket) { 'my_bucket' }
  let(:s3_record) do
    {
      's3' => {
        'bucket' => {
          'name' => s3_bucket
        },
        'object' => {
          'key' => s3_key
        }
      }
    }
  end
  let(:params) { { complete_fulfillment: true } }

  describe 'perform' do
    before :each do
      Fulfillment::RostiShipmentPoller.stub(:sqs_client).and_return(sqs_client)
    end

    let(:sqs_client) do
      client = double('sqs_client')
      result = double('sqs_result')
      result.stub(:messages).and_return(messages)
      client.stub(:receive_message).and_return(result)
      client
    end

    context 'received messages is empty' do
      let(:messages) { [] }
      it 'does not call process_s3_record' do
        Fulfillment::RostiShipmentPoller.should_not_receive(:process_s3_record)
        Fulfillment::RostiShipmentPoller.perform
      end
    end

    context 'received messages is not empty' do
      let(:s3_key) { 'my_key' }
      let(:message_body) do
        '{"Message":"{\"Records\":[{\"s3\":{\"bucket\":{\"name\":\"S3_BUCKET\"},\"object\":{\"key\":\"S3_KEY\"}}}]}"}'
      end
      let(:messages) do
        message = double('message')
        message.stub(:body).and_return(message_body.gsub!('S3_KEY', s3_key).gsub!('S3_BUCKET', s3_bucket))
        message.stub(:receipt_handle)
        [message]
      end
      it 'calls process_s3_record for each s3 record and deletes the message' do
        sqs_client.should_receive(:delete_message)
        Fulfillment::RostiShipmentPoller.should_receive(:process_s3_record).with(s3_record, params)
        Fulfillment::RostiShipmentPoller.perform(params)
      end
    end
  end

  describe 'process_s3_record' do
    context 'object key does not match shipments prefix' do
      let(:s3_key) { 'foo/key.csv' }
      it 'does not import file' do
        Fulfillment::RostiShipmentImporter.should_not_receive(:perform)
        Fulfillment::RostiShipmentPoller.process_s3_record(s3_record, params)
      end
    end

    context 'object key matches shipments prefix' do
      let(:s3_key) { 'shipments/my_shipments.csv' }
      let(:s3_client) do
        client = double('s3_client')
        bucket = double('bucket')
        object = double('object')
        bucket.stub(:object).with(s3_key).and_return(object)
        client.stub(:bucket).with(s3_bucket).and_return(bucket)
        object.stub(:exists?).and_return(key_exists)
        client
      end

      before :each do
        Fulfillment::RostiShipmentPoller.stub(:s3_client).and_return(s3_client)
      end

      context 'object does not exist' do
        let(:key_exists) { false }
        it' does not import the file' do
          Fulfillment::RostiShipmentImporter.should_not_receive(:perform)
          Fulfillment::RostiShipmentPoller.process_s3_record(s3_record, params)
        end
      end

      context 'object key exists' do
        let(:key_exists) { true }
        it 'imports the file and deletes it' do
          Fulfillment::RostiShipmentImporter.should_receive(:perform).with(
            complete_fulfillment: true,
            storage: 's3',
            storage_filename: s3_key
          )
          s3_client.bucket(s3_bucket).object(s3_key).stub(:delete)
          s3_client.bucket(s3_bucket).object(s3_key).should_receive(:delete)
          Fulfillment::RostiShipmentPoller.process_s3_record(s3_record, params)
        end
      end
    end
  end
end
