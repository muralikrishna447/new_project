class MarketplaceOrderExporterMailer < ActionMailer::Base
  default from: 'ChefSteps Marketplace Export <no-reply@chefsteps.com>'
  default reply_to: 'no-reply@chefsteps.com'

  def prepare(params)
    subject = "ChefSteps Marketplace Export for #{params[:vendor]}"
    if params[:success]
      status_msg = "The order export that you requested for #{params[:vendor]} is attached."
    else
      status_msg = "Sorry, the order export that you requested for #{params[:vendor]} failed. Please contact an engineer for help."
    end
    substitutions = {
      sub: {
        '*|SUBJECT|*' => [subject],
        '*|STATUS|*' => [status_msg]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    headers['X-IDEMPOTENCY'] = "ChefSteps Marketplace Order Export for #{params[:vendor]} #{params[:export_id]}"
    if params[:success]
      attachments["#{params[:vendor]}_#{params[:export_id]}.csv"] = {
        mime_type: 'text/csv',
        content: params[:output]
      }
    end
    mail(to: params[:email], subject: subject)
  end
end
