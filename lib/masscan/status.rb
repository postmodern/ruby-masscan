module Masscan
  #
  # Represents a port status record.
  #
  class Status < Struct.new(:status,:protocol,:port,:reason,:ttl,:ip,:timestamp,:mac)

    #
    # Initializes the status record.
    #
    # @param [:open, :closed] status
    #   The status of the port.
    #
    # @param [:icmp, :tcp, :udp, :sctp] protocol
    #   The IP protocol.
    #
    # @param [Integer] port
    #   The port number.
    #
    # @param [Array<:fin, :syn, :rst, :psh, :ack, :urg, :ece, :cwr>, nil] reason
    #   Flags indicating why the port was open or closed.
    #
    # @param [Integer, nil] ttl
    #   TTL.
    #
    # @param [IPAddr] ip
    #   The IP address.
    #
    # @param [Time] timestamp
    #   The record timestamp.
    #
    # @param [String, nil] mac
    #   Optional mac address.
    #
    # @api private
    #
    def initialize(status: , protocol: , port: , reason: nil, ttl: nil, ip: , timestamp: , mac: nil)
      super(status,protocol,port,reason,ttl,ip,timestamp,mac)
    end
  end
end
