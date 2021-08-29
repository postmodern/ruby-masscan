module Masscan
  #
  # Represents a port status record.
  #
  class Status < Struct.new(:status,:protocol,:port,:reason,:ttl,:ip,:timestamp,:mac)
  end
end
