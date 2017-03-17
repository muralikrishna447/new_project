require 'spec_helper'

describe Fulfillment::AwsQueuePoller do
  let(:sqs_prefix) { 'https://sqs.us-east-1.amazonaws.com/021963864089/' }
  let(:task_name) {
    'task_wukawuka'
  }
  let(:env_string) { "test" }
  let(:increment_options) {
    {sporadic: true, source: "#{sqs_prefix}task-poller-#{env_string}-#{task_name}"}
  }

  describe 'perform' do

    before :each do
      Fulfillment::AwsQueuePoller.stub(:sqs_client).and_return(sqs_client)
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
      it 'does not call process_sqs_message' do
        Fulfillment::AwsQueueWorker.stub(:perform)
        Fulfillment::AwsQueuePoller.should_not_receive(:process_sqs_message)
        Fulfillment::AwsQueueWorker.should_not_receive(:perform)
        sqs_client.should_not_receive(:delete_message)

        Librato.should_receive(:increment).with(
            "task.poller.test.#{task_name}.started", increment_options)
        Librato.should_receive(:increment).with(
            "task.poller.test.#{task_name}.attempt.receive", increment_options)
        Librato.should_receive(:increment).with(
            "task.poller.test.#{task_name}.empty.queue", increment_options)
        Librato.should_receive(:increment).with(
            "task.poller.test.#{task_name}.success", increment_options)

        Fulfillment::AwsQueuePoller.perform(task_name)
      end
    end

    context 'received messages is not empty' do

      let(:message_body) do
        'DOIT'
      end
      let(:messages) do
        message = double('message')
        message.stub(:body).and_return(message_body)
        message.stub(:receipt_handle)
        [message]
      end
      it 'calls process_sqs_message successfully and deletes the message' do

        Librato.should_receive(:increment).with(
            "task.poller.test.#{task_name}.started", increment_options)
        Librato.should_receive(:increment).with(
            "task.poller.test.#{task_name}.attempt.receive", increment_options)
        Librato.should_receive(:increment).with(
            "task.poller.test.#{task_name}.received", increment_options)
        Librato.should_receive(:increment).with(
            "task.poller.test.#{task_name}.processing.starting", increment_options)
        Librato.should_receive(:increment).with(
            "task.poller.test.#{task_name}.processing.complete", increment_options)
        Librato.should_receive(:increment).with(
            "task.poller.test.#{task_name}.delete.message", increment_options)
        Librato.should_receive(:increment).with(
            "task.poller.test.#{task_name}.success", increment_options)

        sqs_client.should_receive(:delete_message)
        Fulfillment::AwsQueueWorker.should_receive(:perform).with({
                                                                      :task => task_name,
                                                                      :message => message_body
                                                                  })
        Fulfillment::AwsQueuePoller.perform(task_name)
      end

      context 'dispatch explodes' do

        before :each do
          Fulfillment::AwsQueueWorker.should_receive(:perform).and_raise("method not found")
          Fulfillment::AwsQueuePoller.should_receive(:log_error)
        end

        it 'should not delete the message' do

          Librato.should_receive(:increment).with(
              "task.poller.test.#{task_name}.started", increment_options)
          Librato.should_receive(:increment).with(
              "task.poller.test.#{task_name}.attempt.receive", increment_options)
          Librato.should_receive(:increment).with(
              "task.poller.test.#{task_name}.received", increment_options)
          Librato.should_receive(:increment).with(
              "task.poller.test.#{task_name}.processing.starting", increment_options)
          Librato.should_receive(:increment).with(
              "task.poller.test.#{task_name}.failure", increment_options)

          sqs_client.should_not_receive(:delete_message)

          Fulfillment::AwsQueuePoller.perform(task_name)
        end

      end
    end
  end
end
