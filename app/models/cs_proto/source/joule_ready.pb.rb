#!/usr/bin/env ruby
# Generated by the protocol buffer compiler. DO NOT EDIT!

require 'protocol_buffers'

module CsProto
  # forward declarations
  class JouleReadyQrCode < ::ProtocolBuffers::Message; end

  class JouleReadyQrCode < ::ProtocolBuffers::Message
    set_fully_qualified_name "CsProto.JouleReadyQrCode"

    optional :uint32, :serialNumber, 1
    optional :string, :guideId, 2
    optional :uint32, :bestByDateInSeconds, 3
    optional :uint32, :version, 4
    optional :string, :sku, 5
  end

end
