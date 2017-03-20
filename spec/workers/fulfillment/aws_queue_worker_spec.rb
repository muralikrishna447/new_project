require 'spec_helper'

describe Fulfillment::AwsQueueWorker do
  let(:sqs_prefix) { 'https://sqs.us-east-1.amazonaws.com/021963864089/' }
  let(:task_name) {
    'submit_orders_to_rosti'
  }
  let(:invalid_task_name) {
    'task_wukawuka'
  }
  let(:env_string) { "test" }
  let(:increment_options) {
    {sporadic: true}
  }

  describe 'perform' do

    before :each do
      # Fulfillment::AwsQueueWorker.stub(:sqs_client).and_return(sqs_client)
    end

    context 'received params is empty' do
      let(:params) { {} }
      it 'Raises exception' do
        Fulfillment::AwsQueueWorker.should_not_receive(:dispatch_task)

        Librato.should_receive(:increment).with(
            "aws.queue.worker.unknown.failure", increment_options)

        expect{ Fulfillment::AwsQueueWorker.perform(params) }.to raise_error(KeyError)

      end
    end

    context 'with valid task and empty message' do
      let(:params) { {
          task: task_name
      } }
      it 'Calls dispatch_task with task name' do
        Fulfillment::AwsQueueWorker.should_receive(:dispatch_submit_orders_to_rosti).with(nil)

        Librato.should_receive(:increment).with(
            "aws.queue.worker.#{task_name}.started", increment_options)
        Librato.should_receive(:increment).with(
            "aws.queue.worker.#{task_name}.success", increment_options)

        Fulfillment::AwsQueueWorker.perform(params)
      end
    end

    context 'with invalid task and empty message (not stubbed)' do
      let(:params) { {
          task: invalid_task_name
      } }
      it 'Calls dispatch_task with task name' do
        Librato.should_receive(:increment).with(
            "aws.queue.worker.#{invalid_task_name}.started", increment_options)
        Librato.should_receive(:increment).with(
            "aws.queue.worker.#{invalid_task_name}.failure", increment_options)

        expect{ Fulfillment::AwsQueueWorker.perform(params) }.to raise_error(NoMethodError)
      end
    end



    context 'with task and valid message' do

      let (:message_body){'{ "max_quantity" : 99}' }
      let(:params) { {
          task: task_name,
          message: message_body
      } }
      it 'RostiOrderSubmitter with max_quantity 99 and inline true' do
        Fulfillment::RostiOrderSubmitter.should_receive(:submit_orders_to_rosti).with(99, true)

        Librato.should_receive(:increment).with(
            "aws.queue.worker.#{task_name}.started", increment_options)
        Librato.should_receive(:increment).with(
            "aws.queue.worker.#{task_name}.success", increment_options)

        Fulfillment::AwsQueueWorker.perform(params)
      end
    end
  end
end
