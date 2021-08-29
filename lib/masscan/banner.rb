module Masscan
  #
  # Represents a banner record.
  #
  class Banner < Struct.new(:protocol,:port,:ip,:timestamp,:service,:banner)
  end
end
