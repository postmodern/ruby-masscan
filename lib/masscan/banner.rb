module Masscan
  #
  # Represents a banner record.
  #
  class Banner < Struct.new(:protocol,:port,:ip,:timestamp,:app_protocol,:payload)

    alias service app_protocol
    alias banner payload

  end
end
