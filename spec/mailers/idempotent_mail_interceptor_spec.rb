require 'spec_helper'

describe IdempotentMailInterceptor do
  before :each do
    @message = Mail::Message.new
    @message.subject = "Test mail subject"
    @message.to = 'test@example.org'    
  end
  it 'persists in dynamo when idempotency header set' do
    message_token = @message.header['X-IDEMPOTENCY'] = "idempotent!"
    Timecop.freeze(Time.zone.now.change(nsec: 0)) do
      IdempotentMailInterceptor.stub(:check_and_put_log).with('test@example.org', message_token).and_return(true)
      IdempotentMailInterceptor.delivering_email(@message)
      @message.perform_deliveries.should == true
    end
  end
  
  it 'persists in dynamo when idempotency header not set' do
    Timecop.freeze(Time.zone.now.change(nsec: 0)) do
      message_token = "#{Time.now.utc.iso8601} #{@message.subject}"
      IdempotentMailInterceptor.stub(:check_and_put_log).with('test@example.org', message_token).and_return(true)
      IdempotentMailInterceptor.delivering_email(@message)
      @message.perform_deliveries.should == true
    end
  end
  
  it 'blocks delivery when entry already in dynamo' do
    message_token = @message.header['X-IDEMPOTENCY'] = "idempotent!"
    IdempotentMailInterceptor.stub(:check_and_put_log).with('test@example.org', message_token)
      .and_return(false)
    
    Timecop.freeze(Time.zone.now.change(nsec: 0)) do
      IdempotentMailInterceptor.delivering_email(@message)
      @message.perform_deliveries.should == false
    end
  end
  
  it 'throws when trying to send message in sending status' do
    message_token = @message.header['X-IDEMPOTENCY'] = "idempotent!"
    # Not the smartest test since it's mocking a critical method
    IdempotentMailInterceptor.stub(:check_and_put_log).with('test@example.org', message_token)
      .and_raise(Exception.new)
    
    Timecop.freeze(Time.zone.now.change(nsec: 0)) do
      expect { 
        IdempotentMailInterceptor.delivering_email(@message)
       }.to raise_error
    end
  end
  
  it 'marks as delivered' do
    message_token = @message.header['X-IDEMPOTENCY'] = "idempotent!"
    IdempotentMailInterceptor.stub(:log_update).with('test@example.org', message_token)
    IdempotentMailInterceptor.delivered_email(@message)
  end
  
  it 'throws when trying to send to multiple addresses' do
    @message.to = ['a@b.com','c@d.com']
    expect { 
      IdempotentMailInterceptor.delivering_email(@message)
     }.to raise_error
     
     expect { 
       IdempotentMailInterceptor.delivered_email(@message)
      }.to raise_error
  end
end
