require 'spec_helper'

module Fixtures
  DIR = File.join(__dir__,'fixtures')

  def self.join(*names)
    File.join(DIR,*names)
  end
end
