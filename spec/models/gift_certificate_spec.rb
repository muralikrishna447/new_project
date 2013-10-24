require 'spec_helper'

describe GiftCertificate do

  describe "creates a random token of at least 6 letters" do
    gc = GiftCertificate.new
    gc.token.length.should >= 6
  end
end
