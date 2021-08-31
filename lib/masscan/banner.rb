module Masscan
  #
  # Represents a banner record.
  #
  class Banner < Struct.new(:protocol,:port,:ip,:timestamp,:service,:payload)

    alias banner payload

  end
end
