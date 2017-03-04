require 'spec_helper'

describe Fraud::PaymentProcessor do
  describe 'perform' do
    let(:order_id) { 1234 }
    let(:order) { ShopifyAPI::Order.new(id: order_id) }
    before :each do
      ShopifyAPI::Order.stub(:find).with(order_id).and_return(order)
      Fraud::PaymentProcessor.stub(:signifyd_case).with(order).and_return(signifyd_case)
    end

    context 'order is capturable' do
      before :each do
        Fraud::PaymentProcessor.stub(:capturable?).with(order).and_return(true)
      end
      context 'signifyd case exists' do
        let(:signifyd_case) { double('signifyd_case') }
        it 'calls process_capturable_order' do
          Fraud::PaymentProcessor.should_receive(:process_capturable_order).with(order, signifyd_case)
          Fraud::PaymentProcessor.perform(order_id)
        end
      end

      context 'signifyd case does not exist' do
        let(:signifyd_case) { nil }
        context 'order_is_new? returns true' do
          before :each do
            Fraud::PaymentProcessor.stub(:order_is_new?).with(order).and_return(true)
          end
          it 'does not raise error' do
            Fraud::PaymentProcessor.perform(order_id)
          end
        end

        context 'order_is_new? returns false' do
          before :each do
            Fraud::PaymentProcessor.stub(:order_is_new?).with(order).and_return(false)
          end
          it 'raises error' do
            expect { Fraud::PaymentProcessor.perform(order_id) }.to raise_error
          end
        end
      end
    end

    context 'order is not capturable' do
      before :each do
        Fraud::PaymentProcessor.stub(:capturable?).with(order).and_return(false)
      end

      context 'order_has_score? returns true' do
        let(:signifyd_case) { nil }
        before :each do
          Fraud::PaymentProcessor.stub(:order_has_score?).with(order).and_return(true)
        end

        it 'does not call close_signifyd_case' do
          Fraud::PaymentProcessor.should_not_receive(:close_signifyd_case).with(order, signifyd_case)
          Fraud::PaymentProcessor.perform(order_id)
        end
      end

      context 'order_has_score? returns false' do
        before :each do
          Fraud::PaymentProcessor.stub(:order_has_score?).with(order).and_return(false)
        end

        context 'signifyd case exists' do
          let(:signifyd_case) { double('signifyd_case') }
          it 'calls close_signifyd_case' do
            Fraud::PaymentProcessor.should_receive(:close_signifyd_case).with(order, signifyd_case)
            Fraud::PaymentProcessor.perform(order_id)
          end
        end

        context 'signifyd case does not exist' do
          let(:signifyd_case) { nil }
          it 'does not call close_signifyd_case' do
            Fraud::PaymentProcessor.should_not_receive(:close_signifyd_case).with(order, signifyd_case)
            Fraud::PaymentProcessor.perform(order_id)
          end
        end
      end
    end
  end

  describe 'process_capturable_order' do
    let(:fraud_score) { 0 }
    let(:signifyd_case) { { 'score' => fraud_score } }
    let(:order) { ShopifyAPI::Order.new(id: 1) }
    before :each do
      Fraud::PaymentProcessor.stub(:add_score_to_order).with(order, fraud_score)
    end

    context 'order contains only premium' do
      before do
        Shopify::Utils.stub(:contains_only_premium?).with(order).and_return(true)
      end
      it 'calls close_signifyd_case and does not call capture_and_close' do
        Fraud::PaymentProcessor.should_receive(:close_signifyd_case).with(order, signifyd_case)
        Fraud::PaymentProcessor.should_not_receive(:capture_and_close)
        Fraud::PaymentProcessor.process_capturable_order(order, signifyd_case)
      end
    end

    context 'order fraud score is above minimum' do
      let(:fraud_score) { 999 }
      before do
        Shopify::Utils.stub(:contains_only_premium?).with(order).and_return(false)
      end
      it 'calls capture_and_close' do
        Fraud::PaymentProcessor.should_receive(:capture_and_close).with(order, signifyd_case)
        Fraud::PaymentProcessor.process_capturable_order(order, signifyd_case)
      end
    end

    context 'order fraud score is below minimum' do
      before do
        Shopify::Utils.stub(:contains_only_premium?).with(order).and_return(false)
      end
      it 'does not call capture_and_close' do
        Fraud::PaymentProcessor.should_not_receive(:capture_and_close)
        Fraud::PaymentProcessor.process_capturable_order(order, signifyd_case)
      end
    end
  end

  describe 'signifyd_case' do
    let(:order_number) { 123 }
    let(:order) { ShopifyAPI::Order.new(order_number: order_number) }

    context 'response code is 200' do
      let(:signifyd_case) { double('signifyd_case') }
      let(:signifyd_response) do
        {
          code: 200,
          body: signifyd_case
        }
      end
      before do
        Signifyd::Case.stub(:find).with(order_id: order_number).and_return(signifyd_response)
      end
      it 'returns case by order number' do
        expect(Fraud::PaymentProcessor.signifyd_case(order)).to be signifyd_case
      end
    end

    context 'response code is not 200' do
      let(:signifyd_case) { double('signifyd_case') }
      let(:signifyd_response) do
        {
          code: 500,
          body: signifyd_case
        }
      end
      before do
        Signifyd::Case.stub(:find).with(order_number).and_return(signifyd_response)
      end
      it 'raises exception' do
        expect { Fraud::PaymentProcessor.signifyd_case(order) }.to raise_error
      end
    end
  end

  describe 'add_score_to_order' do
    let(:order_id) { 1234 }
    let(:order) do
      ShopifyAPI::Order.new(
        id: order_id,
        note_attributes: note_attributes
      )
    end
    let(:risk) do
      risk = ShopifyAPI::OrderRisk.new(
        display: true,
        message: "The Signifyd fraud score is #{signifyd_score}.",
        recommendation: recommendation,
        score: shopify_score,
        source: 'external'
      )
      risk.prefix_options[:order_id] = order_id
      risk
    end

    context 'score has already been added' do
      let(:note_attributes) do
        [
          ShopifyAPI::NoteAttribute.new(
            name: Fraud::PaymentProcessor::SIGNIFYD_SCORE_ATTR_NAME,
            value: '900'
          )
        ]
      end
      it 'does not save order or risk' do
        Shopify::Utils.should_not_receive(:send_assert_true)
      end
    end

    context 'score has not been previously added' do
      let(:note_attributes) { [] }
      let(:saved_order) do
        ShopifyAPI::Order.new(
          id: order_id,
          note_attributes: [
            ShopifyAPI::NoteAttribute.new(
              name: Fraud::PaymentProcessor::SIGNIFYD_SCORE_ATTR_NAME,
              value: signifyd_score
            )
          ]
        )
      end

      context 'score is above minimum' do
        let(:signifyd_score) { 600 }
        let(:recommendation) { 'accept' }
        let(:shopify_score) { 0.4 }
        it 'saves order risk to shopify with accept recommendation' do
          Shopify::Utils.should_receive(:send_assert_true).with(saved_order, :save)
          Shopify::Utils.should_receive(:send_assert_true).with(risk, :save)
          Librato.should_not_receive(:increment).with('fraud.payment-processor.orders.lowscore.count', sporadic: true)
          Fraud::PaymentProcessor.add_score_to_order(order, signifyd_score)
        end
      end

      context 'score is below minimum' do
        let(:signifyd_score) { 400 }
        let(:recommendation) { 'accept' }
        let(:shopify_score) { 0.6 }
        it 'saves order risk to shopify with investigate recommendation' do
          Shopify::Utils.should_receive(:send_assert_true).with(saved_order, :save)
          Shopify::Utils.should_receive(:send_assert_true).with(risk, :save)
          Librato.should_receive(:increment).with('fraud.payment-processor.orders.lowscore.count', sporadic: true)
          Fraud::PaymentProcessor.add_score_to_order(order, signifyd_score)
        end
      end
    end
  end

  describe 'capture_and_close' do
    let(:order) { double('order') }
    let(:signifyd_case) { double('signifyd_case') }
    it 'calls capture_payment and close_signifyd_case' do
      Fraud::PaymentProcessor.should_receive(:capture_payment).with(order)
      Fraud::PaymentProcessor.should_receive(:close_signifyd_case).with(order, signifyd_case)
      Fraud::PaymentProcessor.capture_and_close(order, signifyd_case)
    end
  end

  describe 'close_signifyd_case' do
    let(:case_id) { 1234 }
    let(:order) { double('order') }
    let(:signifyd_case) do
      {
        'caseId' => case_id,
        'status' => status
      }
    end

    context 'case is already closed' do
      let(:status) { 'DISMISSED' }
      it 'does not close case' do
        Signifyd::Case.should_not_receive(:update)
        Fraud::PaymentProcessor.close_signifyd_case(order, signifyd_case)
      end
    end

    context 'case is open' do
      let(:status) { 'OPEN' }
      it 'updates signifyd case with closed status' do
        Signifyd::Case.should_receive(:update).with(case_id, 'status' => 'DISMISSED')
        Fraud::PaymentProcessor.close_signifyd_case(order, signifyd_case)
      end
    end
  end

  describe 'order_is_new?' do
    let(:order) do
      ShopifyAPI::Order.new(
        id: 1234,
        processed_at: processed_at_time.iso8601
      )
    end

    context 'order was placed within the past hour' do
      let(:processed_at_time) { Time.new(2017, 2, 1, 12, 0, 0) }
      it 'returns true' do
        Timecop.freeze(processed_at_time + 60) do
          expect(Fraud::PaymentProcessor.order_is_new?(order)).to be_true
        end
      end
    end

    context 'order was placed more than one hour ago' do
      let(:processed_at_time) { Time.new(2017, 2, 1, 12, 0, 0) }
      it 'returns true' do
        Timecop.freeze(processed_at_time + 3660) do
          expect(Fraud::PaymentProcessor.order_is_new?(order)).to be_false
        end
      end
    end
  end

  describe 'order_has_score?' do
    let(:order) do
      ShopifyAPI::Order.new(
        id: 1234,
        note_attributes: note_attributes
      )
    end

    context 'order has score note attribute' do
      let(:note_attributes) do
        [
          ShopifyAPI::NoteAttribute.new(
            name: Fraud::PaymentProcessor::SIGNIFYD_SCORE_ATTR_NAME,
            value: '900'
          )
        ]
      end

      it 'returns true' do
        expect(Fraud::PaymentProcessor.order_has_score?(order)).to be_true
      end
    end

    context 'order metafields does not contain key' do
      let(:note_attributes) { [] }
      it 'returns false' do
        expect(Fraud::PaymentProcessor.order_has_score?(order)).to be_false
      end
    end
  end
end
