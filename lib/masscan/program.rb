require 'masscan/command'

module Masscan
  #
  # @deprecated Please use {Command} instead.
  #
  class Program < Command

    #
    # Runs `masscan`.
    #
    # @param [Hash{Symbol => Object}] options
    #   Additional options for masscan.
    #
    # @param [Hash{Symbol => Object}] kwargs
    #   Additional keyword arguments for masscan.
    #
    # @yield [masscan]
    #   If a block is given, it will be passed the new masscan instance
    #   used to specify options for masscan.
    #
    # @yieldparam [Masscan] masscan
    #   The masscan instance.
    #
    # @return [Boolean]
    #   Specifies whether the command exited normally.
    #
    # @example Specifying `masscan` options via a Hash:
    #   Masscan::Command.scan(
    #     ips: '192.168.1.1/24',
    #     ports: [22, 80, 443],
    #   )
    #
    # @example Specifying `masscan` options via a block:
    #   Masscan::Command.scan do |masscan|
    #     masscan.ips = '192.168.1.1/24'
    #     masscan.ports = [22, 80, 443]
    #   end
    #
    def self.scan(options={},&block)
      run(options,&block)
    end

    #
    # Runs `masscan` but under `sudo`.
    #
    # @see scan
    #
    def self.sudo_scan(options={},&block)
      sudo(options,&block)
    end

  end
end
