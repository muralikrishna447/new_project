include ActionView::Helpers::NumberHelper

def format_currency(amount)
  number_to_currency(amount.to_i / 100)
end

class GenericReceiptMailer < BaseMandrillMailer
  def prepare(order)
    subject = "ChefSteps Receipt"
    user = order.user
    lines = order.stripe_items
    merge_vars = {
      "ITEM1_NAME" => lines[0][:description],
      "ITEM1_PRICE" => format_currency(lines[0][:amount]),
      "ITEM2_NAME" => lines.count > 1 ? lines[1][:description] : "",
      "ITEM2_PRICE" => lines.count > 1 ? format_currency(lines[1][:amount]) : "",
      "SUBTOTAL" => "DANTODO-subtotal",
      "TAX" => "DANTODO-tax",
      "TOTAL" => "DANTODO-total",
      "PURCHASE_DATE" => DateTime.now.strftime('%B %d, %Y'),
      "CARD_AND_LAST4" => "DANTODO-cardandlast4",
      "ORDER_ID" => "DANTODO-orderid"
    }

    body = mandrill_template("generic-receipt", merge_vars)
    send_mail(user.email, subject, body)
  end
end