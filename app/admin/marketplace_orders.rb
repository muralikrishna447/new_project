ActiveAdmin.register_page 'Marketplace Orders' do
  content do
    form action: admin_marketplace_orders_export_path, method: :post do |f|
      f.input name: 'authenticity_token', type: :hidden, value: form_authenticity_token.to_s
      f.input :vendor, type: :text, name: 'vendor'
      f.input :email, type: :text, name: 'email'
      f.input :submit, type: :submit, name: nil
    end
  end

  page_action :export, method: :post do
    Rails.logger.info 'Marketplace Export admin starting export for ' \
                      "vendor #{params[:vendor]} and email #{params[:email]}"
    Resque.enqueue(
      Fulfillment::MarketplaceOrderExporter,
      vendor: params[:vendor],
      email: params[:email]
    )
    redirect_to(
      admin_marketplace_orders_path,
      notice: "Export started! You should receive it at #{params[:email]} within a few minutes."
    )
  end
end
