def fetch_status_count(redemption_status:)
  PremiumGiftCertificate.where(redeemed: redemption_status)
                        .group(:premium_gift_certificate_group_id)
                        .count
end

ActiveAdmin.register PremiumGiftCertificateGroup do
  actions :index, :new
  form partial: 'form'

  filter :title
  filter :coupon_count
  filter :coupon_creation_status
  filter :created_at

  permit_params :title, :coupon_count, :created_by_id

  index do
    redeemed_counts = fetch_status_count(redemption_status: true)
    un_redeemed_counts = fetch_status_count(redemption_status: false)
    column :title
    column :created_by
    column 'Total', :coupon_count
    column 'Redeemed' do |obj|
      redeemed_counts[obj.id] || 0
    end
    column 'Un Redeemed' do |obj|
      un_redeemed_counts[obj.id] || 0
    end
    column 'Download coupon report', :coupon_creation_status do |obj|
      if obj.coupon_creation_status
        link_to('Download Coupons', get_all_coupons_admin_premium_gift_certificate_group_path(obj.id))
      else
        'In Progress'
      end
    end
  end

  controller do

    def create
      params[:premium_gift_certificate_group][:title].strip!
      params[:premium_gift_certificate_group][:created_by_id] = current_user.id
      super
    end

    private

    def cert_group_params
      params.require(:premium_gift_certificate_group)
            .permit(:title, :coupon_count)
            .merge(created_by_id: current_user.id)
    end
  end

  member_action :get_all_coupons, :method => :get do
    attributes = ['Coupon Codes', 'Redemption Status' ,'User Email']
    cert_group = PremiumGiftCertificateGroup.find(params[:id])
    csv_string = CSV.generate(headers: true) do |csv|
      csv << attributes
      cert_group.premium_gift_certificates.coupon_redeemed.joins(:user).select('premium_gift_certificates.id, token, users.email as purchaser_email')
                .find_each(batch_size: 1000) do |coupon|
        csv << [coupon.token, 'Yes', coupon.purchaser_email]
      end
      cert_group.premium_gift_certificates.unredeemed.find_each(batch_size: 1000) do |coupon|
        csv << [coupon.token, 'No', nil]
      end
    end
    send_data csv_string, filename: "#{cert_group.title} coupon report.csv"
  end
end
