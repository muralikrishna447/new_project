class JouleAddressMailer < ActionMailer::Base
  default from: "Team ChefSteps <info@chefsteps.com>"
  default reply_to: "info@chefsteps.com"

  def prepare(order)
    user_email = order.email
    logger.info("Preparing joule address change mail for user [#{user_email}]")
    order_id = order.id
    order_name = order.name
    shipping_address = order.shipping_address
    user_name = shipping_address.name
    subject = "Important: Verify Your Shipping Address For Joule"
    base_url = Rails.application.config.shared_config[:chefsteps_endpoint]

    substitutions = {
      sub: {
        "*|SUBJECT|*" => [subject],
        "*|NAME|*" => [user_name],
        "*|CURRENT_YEAR|*" => [Time.now.year],
        "*|ADDRESS_1|*" => [shipping_address.address1],
        "*|ADDRESS_2|*" => [shipping_address.address2],
        "*|CITY|*" => [shipping_address.city],
        "*|PROVINCE|*" => [shipping_address.province],
        "*|ZIP|*" => [shipping_address.zip],
        "*|ORDER_ID|*" => [order_id],
        "*|ORDER_NAME|*" => [order_name],
        "*|UPDATE_URL|*" => [base_url + "/orders/#{order_id}/update-address"],
        "*|CONFIRM_URL|*" => [base_url + "/orders/#{order_id}/address-confirmed"]
      }
    }

    headers['X-SMTPAPI'] = substitutions.to_json
    headers['X-IDEMPOTENCY'] = "Important: Verify Your Shipping Address For Joule #{order_id}"
    mail(to: user_email, subject: subject)
  end
end
