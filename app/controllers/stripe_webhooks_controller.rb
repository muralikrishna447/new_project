class StripeWebhooksController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    Rails.logger.info("Received Stripe Webook #{params[:id]}")
    # TODO check shared param between Stripe
    unless StripeEvent.exists?(event_id: params[:id])
      event_at = params[:created].present? ? Time.at(params[:created]) : nil
      stripe_event = StripeEvent.create!(event_id: params[:id], object: params[:object], api_version: params[:api_version],
        request_id: params[:request_id], event_type: params[:type], created: params[:created],
        event_at: event_at, livemode: params[:livemode], data: params[:data])
      # Resque.enqueue(StripeWebhookProcessor, stripe_event.id)
    end
    render(nothing: true, status: :ok)
  end
end
