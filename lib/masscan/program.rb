require 'masscan/task'

require 'rprogram/program'

module Masscan
  #
  # Represents the `masscan` program.
  #
  class Program < RProgram::Program

    name_program 'masscan'

    #
    # Finds the `masscan` program and performs a scan.
    #
    # @param [Hash{Symbol => Object}] options
    #   Additional options for masscan.
    #
    # @param [Hash{Symbol => Object}] exec_options
    #   Additional exec-options.
    #
    # @yield [task]
    #   If a block is given, it will be passed a task object
    #   used to specify options for masscan.
    #
    # @yieldparam [Task] task
    #   The masscan task object.
    #
    # @return [Boolean]
    #   Specifies whether the command exited normally.
    #
    # @example Specifying `masscan` options via a Hash.
    #   Masscan::Program.scan(
    #     ips: '192.168.1.1/24',
    #     ports: [22, 80, 443],
    #   )
    #
    # @example Specifying `masscan` options via a {Task} object.
    #   Masscan::Program.scan do |masscan|
    #     masscan.ips = '192.168.1.1/24'
    #     masscan.ports = [22, 80, 443]
    #   end
    #
    # @see #scan
    #
    def self.scan(options={},exec_options={},&block)
      find.scan(options,exec_options,&block)
    end

    #
    # Finds the `masscan` program and performs a scan, but runs `masscan` under
    # `sudo`.
    #
    # @see scan
    #
    # @since 0.8.0
    #
    def self.sudo_scan(options={},exec_options={},&block)
      find.sudo_scan(options,exec_options,&block)
    end

    #
    # Performs a scan.
    #
    # @param [Hash{Symbol => Object}] options
    #   Additional options for masscan.
    #
    # @param [Hash{Symbol => Object}] exec_options
    #   Additional exec-options.
    #
    # @yield [task]
    #   If a block is given, it will be passed a task object
    #   used to specify options for masscan.
    #
    # @yieldparam [Task] task
    #   The masscan task object.
    #
    # @return [Boolean]
    #   Specifies whether the command exited normally.
    #
    # @see http://rubydoc.info/gems/rprogram/0.3.0/RProgram/Program#run-instance_method
    #   For additional exec-options.
    #
    def scan(options={},exec_options={},&block)
      run_task(Task.new(options,&block),exec_options)
    end

    #
    # Performs a scan and runs `masscan` under `sudo`.
    #
    # @see #scan
    #
    # @since 0.8.0
    #
    def sudo_scan(options={},exec_options={},&block)
      sudo_task(Task.new(options,&block),exec_options)
    end

  end
end
