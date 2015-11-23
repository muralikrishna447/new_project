include ActionView::Helpers::NumberHelper

def format_currency(amount)
  number_to_currency(amount.to_i / 100.0)
end

class GenericReceiptMailer < BaseMandrillMailer

  def format_address(shipping)
    addr = shipping[:address]
    <<-ADDRESS
    #{shipping[:name]}
    <br>#{addr[:line1]}#{addr[:line2] + "<br>" if addr[:line2]}
    <br>#{addr[:city]}, #{addr[:state]} #{addr[:postal_code]}
    ADDRESS
  end

  def prepare(order, stripe_charge)

    subject = "ChefSteps Receipt"
    user = order.user
    lines = order.stripe_items

    total = stripe_charge.amount
    subtotal = total
    tax = 0
    tax_line = stripe_charge.items.find { |i| i.type == "tax" }
    if tax_line
      tax = tax_line.amount
      subtotal = subtotal - tax
    end

    # If Joule and including premium for free, document that
    if lines.count == 1 && lines[0][:parent] == 'cs10001'
      lines << {
        amount: 0,
        currency: 'usd',
        description: 'ChefSteps Premium',
        parent: 'cs10002',
        quantity: 1,
        type: 'sku'
      }
    end

    card = Stripe::Charge.retrieve(stripe_charge.charge).card

    merge_vars = {
      "ITEM1_NAME" => lines[0][:description],
      "ITEM1_PRICE" => format_currency(lines[0][:amount]),
      "ITEM2_NAME" => lines.count > 1 ? lines[1][:description] : "",
      "ITEM2_PRICE" => lines.count > 1 ? format_currency(lines[1][:amount]) : "",
      "SUBTOTAL" => format_currency(subtotal),
      "TAX" => format_currency(tax),
      "TOTAL" => format_currency(total),
      "PURCHASE_DATE" => DateTime.now.strftime('%B %d, %Y'),
      "CARD_AND_LAST4" => card.brand + " " + card.last4,
      "ORDER_ID" => stripe_charge.id,
      "SHIPPING_ADDRESS" => format_address(stripe_charge.shipping)
    }

    body = mandrill_template("generic-receipt", merge_vars)
    send_mail(user.email, subject, body)
  end
end
