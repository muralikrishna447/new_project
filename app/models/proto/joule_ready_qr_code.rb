module Proto
  class JouleReadyQrCode < ProtocolBuffers::Message
    optional :uint32, :serialNumber, 1
    optional :string, :guideId, 2
    optional :uint32, :bestByDateInSeconds, 3
    optional :uint32, :version, 4
    optional :string, :sku, 5
  end
end