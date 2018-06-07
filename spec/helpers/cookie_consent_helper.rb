require 'spec_helper'

describe CookieConsentHelper, type: :helper do

  describe 'is_consent_needed?' do

    context 'country is US' do
      let(:get_country) {'US'}

      it 'returns false' do
        expect(is_consent_needed?).to eq(false)
      end
    end

    context 'country is FR' do
      let(:get_country) {'FR'}

      context 'get_consent_cookie? is accept' do
        let(:get_consent_cookie?) {'accept'}

        it 'returns false when already consented' do
          expect(is_consent_needed?).to eq(false)
        end
      end

      context 'get_consent_cookie? is nil' do
        let(:get_consent_cookie?) {nil}

        it 'returns true when not yet consented' do
          expect(is_consent_needed?).to eq(true)
        end
      end

    end

    context 'country is nil' do
      let(:get_country) {nil}

      it 'returns false' do
        expect(is_consent_needed?).to eq(false)
      end
    end

  end

end