require 'protocol_buffers'
require 'base64'

# 2019-03-25T15:10:21.321 INFO - V0:CHsSBkFCQ1hZWhiAgMfnBQ==
# 2019-03-25T15:10:21.321 INFO - V0e:CHsSBkFCQ1hZWhiAgMfnBQ%3D%3D
# 2019-03-25T15:10:21.322 INFO - V0:CHsSBkFCQ1hZWhiAgMfnBSABKgdjczQwMDAx
# 2019-03-25T15:10:21.322 INFO - V0e:CHsSBkFCQ1hZWhiAgMfnBSABKgdjczQwMDAx
# 2019-03-25T15:10:21.322 INFO - QrCodesController#jr:some


class QrCodesController < ApplicationController
  def jr
    @qr_base64_encoded_protobuf = params[:base64_encoded_protobuf]
    Rails.logger.info "QrCodesController#jr:base64:#{@qr_base64_encoded_protobuf}"

    begin
      if @qr_base64_encoded_protobuf.present?
        @qr_decoded = Base64.decode64 @qr_base64_encoded_protobuf
        @qr_code = CsProto::JouleReadyQrCode.parse(@qr_decoded)
        Rails.logger.info "QrCodesController#jr:JSON:#{@qr_code.to_json}"

        # Since all fields are optional we don't have a clean way to see
        # If this was parsed at all
        if @qr_code.valid? && (@qr_code.sku.present? || @qr_code.guideId.present?)
          @qr_redirect_url = select_redirect_url(@qr_code)
        else
          Rails.logger.error "QrCodesController::jr:no sku and no guideId"
        end
      end
    rescue StandardError => e
      Rails.logger.error "QrCodesController::jr #{e.class.name} #{e.message} QrCodesController#jr:#{@qr_base64_encoded_protobuf}"
    end

    redirect_to @qr_redirect_url || ENV['DEFAULT_QR_CODE_REDIRECT'] || DEFAULT_QR_CODE_REDIRECT
  end


  private

  DEFAULT_QR_CODE_REDIRECT = '/joule/app'

  def select_redirect_url(code)
    if code.guideId.present?
      guide_url(code.guideId)
    end
  end

  def lookup_guide_activity(guide_id)
    GuideActivity.where(guide_id: guide_id).first
  end
  #
  # class JouleReadyItemV0 < ProtocolBuffers::Message
  #   optional :uint32, :serialNumber, 1
  #   optional :string, :guideId, 2
  #   optional :uint32, :bestByDateInSeconds, 3
  # end
  #
  # class JouleReadyItemV1 < ProtocolBuffers::Message
  #   optional :uint32, :serialNumber, 1
  #   optional :string, :guideId, 2
  #   optional :uint32, :bestByDateInSeconds, 3
  #   optional :uint32, :version, 4
  #   optional :string, :sku, 5
  # end
  #
  #
  # def jr_example
  #
  #
  #   msg = JouleReadyItemV0.new(
  #     serialNumber: 123,
  #     guideId: 'ABCXYZ',
  #     bestByDateInSeconds: Time.new(2019, 6, 1, 0, 0, 0, 0).to_i
  #   )
  #
  #   v0 = Base64.strict_encode64(msg.serialize_to_string)
  #   v0e = CGI::escape v0
  #   Rails.logger.info 'V0:' + v0
  #   Rails.logger.info 'V0e:' + v0e
  #
  #
  #   msg = JouleReadyItemV1.new(
  #     serialNumber: 123,
  #     guideId: 'ABCXYZ',  # At some point we will stop including this, using just sku instead
  #     bestByDateInSeconds: Time.new(2019, 6, 1, 0, 0, 0, 0).to_i,
  #     version: 1,
  #     sku: 'cs40001'
  #   )
  #
  #   v1 = Base64.strict_encode64(msg.serialize_to_string)
  #   v1e = CGI::escape v1
  #   Rails.logger.info 'V0:' + v1
  #   Rails.logger.info 'V0e:' + v1e
  #
  #
  #
  # end
end
