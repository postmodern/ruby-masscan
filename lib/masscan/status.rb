module Masscan
  class Status < Struct.new(:status,:protocol,:port,:ip,:timestamp,:mac)
  end
end
