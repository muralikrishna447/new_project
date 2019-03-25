require 'spec_helper'

describe QrCodesController do
  describe "#jr" do
    context 'with no QR code' do
      it "should show an error" do
        expect { get :jr }.to_not raise_error
        expect(response.status).to eq 422
      end
    end
    context 'with invalid QR encoding' do
      let(:base64_encoded_protobuf) { 'ASDASDS' }
      it "should show an error" do
        expect { get :jr,  base64_encoded_protobuf: base64_encoded_protobuf}.to_not raise_error
        expect(response.status).to eq 422
      end
    end
    context 'with valid v0 QR code' do
      let(:base64_encoded_protobuf) { 'CHsSBkFCQ1hZWhiAgMfnBQ==' }
      it "should show an error" do
        expect { get :jr,  base64_encoded_protobuf: base64_encoded_protobuf}.to_not raise_error
        expect(response.status).to eq 200
        json = (JSON.parse(response.body))["payload"]
        expect(json.delete("serialNumber")).to eq 123
        expect(json.delete("guideId")).to eq 'ABCXYZ'
        expect(json.delete("bestByDateInSeconds")).to eq 1559347200
        expect(json).to eq({})
      end
    end
    context 'with valid v1 QR code' do
      let(:base64_encoded_protobuf) { 'CHsSBkFCQ1hZWhiAgMfnBSABKgdjczQwMDAx' }
      it "should show an error" do
        expect { get :jr,  base64_encoded_protobuf: base64_encoded_protobuf}.to_not raise_error
        expect(response.status).to eq 200
        json = (JSON.parse(response.body))["payload"]
        expect(json.delete("version")).to eq 1
        expect(json.delete("serialNumber")).to eq 123
        expect(json.delete("guideId")).to eq 'ABCXYZ'
        expect(json.delete("bestByDateInSeconds")).to eq 1559347200
        expect(json.delete("sku")).to eq 'cs40001'
        expect(json).to eq({})
      end
    end
  end
end
