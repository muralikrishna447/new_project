require 'spec_helper'

describe QrCodesController do
  describe "#jr" do

    context 'with no QR code' do
      it "should redirect to joule app page" do
        expect {get :jr}.to_not raise_error
        expect(response.status).to eq 302
        expect(response.location).to eq 'http://test.host/joule/app'
      end
    end
    context 'with invalid QR encoding' do
      let(:base64_encoded_protobuf) {'ASDASDS'}
      it "should show an error" do
        expect {get :jr, params: {base64_encoded_protobuf: base64_encoded_protobuf}}.to_not raise_error
        expect(response.status).to eq 302
        expect(response.location).to eq 'http://test.host/joule/app'
      end
    end
    context 'with valid v0 QR code' do
      let(:base64_encoded_protobuf) {'CHsSBkFCQ1hZWhiAgMfnBQ=='}
      it "should show an error" do
        expect {get :jr, params: {base64_encoded_protobuf: base64_encoded_protobuf}}.to_not raise_error
        expect(response.status).to eq 302
        expect(response.location).to eq 'http://test.host/guides/ABCXYZ'
        expect(assigns(:qr_code).serialNumber).to eq 123
        expect(assigns(:qr_code).guideId).to eq 'ABCXYZ'
        expect(assigns(:qr_code).bestByDateInSeconds).to eq 1559347200
      end
    end
    context 'with valid v1 QR code' do
      let(:base64_encoded_protobuf) {'CHsSBkFCQ1hZWhiAgMfnBSABKgdjczQwMDAx'}
      it "should show an error" do
        expect {get :jr, params: {base64_encoded_protobuf: base64_encoded_protobuf}}.to_not raise_error
        expect(response.status).to eq 302
        expect(response.location).to eq 'http://test.host/guides/ABCXYZ'
        expect(assigns(:qr_code).version).to eq 1
        expect(assigns(:qr_code).serialNumber).to eq 123
        expect(assigns(:qr_code).guideId).to eq 'ABCXYZ'
        expect(assigns(:qr_code).bestByDateInSeconds).to eq 1559347200
        expect(assigns(:qr_code).sku).to eq 'cs40001'
      end
    end
  end
end
