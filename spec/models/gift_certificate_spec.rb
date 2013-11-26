require 'spec_helper'

describe GiftCertificate do

  describe "creates a random token of at least 6 characters" do
    gc = GiftCertificate.new
    gc.token.length.should >= 6
  end
end
