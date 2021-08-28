module Masscan
  class Banner < Struct.new(:protocol,:port,:ip,:timestamp,:service,:banner)
  end
end
