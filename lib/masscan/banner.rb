module Masscan
  #
  # Represents a banner record.
  #
  class Banner < Struct.new(:protocol,:port,:ttl,:ip,:timestamp,:app_protocol,:payload)

    #
    # Initializes the banner.
    #
    # @param [:icmp, :tcp, :udp, :sctp] protocol
    #   The IP protocol.
    #
    # @param [Integer] port
    #   The port number.
    #
    # @param [Integer, nil] ttl
    #   The optional TTL.
    #
    # @praam [IPAddr] ip
    #   The IP address.
    #
    # @param [Time] timestamp
    #   The record timestamp.
    #
    # @param [Symbol] app_protocol
    #   The application protocol.
    #
    # @param [String] payload
    #   The banner/capture payload.
    #
    # @api private
    #
    def initialize(protocol: , port: , ttl: nil, ip: , timestamp: , app_protocol: , payload: )
      super(protocol,port,ttl,ip,timestamp,app_protocol,payload)
    end

    alias service app_protocol
    alias banner payload

  end
end
