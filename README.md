# ruby-masscan

[![CI](https://github.com/postmodern/ruby-masscan/actions/workflows/ruby.yml/badge.svg)](https://github.com/postmodern/ruby-masscan/actions/workflows/ruby.yml)
[![Code Climate](https://codeclimate.com/github/postmodern/ruby-masscan.svg)](https://codeclimate.com/github/postmodern/ruby-masscan)
[![Gem Version](https://badge.fury.io/rb/ruby-masscan.svg)](https://badge.fury.io/rb/ruby-masscan)

* [Source](https://github.com/postmodern/ruby-masscan/)
* [Issues](https://github.com/postmodern/ruby-masscan/issues)
* [Documentation](http://rubydoc.info/gems/ruby-masscan/frames)

## Description

A Ruby interface to [masscan], an Internet-scale port scanner.
Allows automating masscan and parsing masscan Binary, List, and JSON output
file formats.

## Features

* Provides a Ruby interface for running masscan.
* Supports parsing masscan Binary, List, and JSON output files.

## Examples

Run `sudo masscan` from Ruby:

```ruby
require 'masscan/program'

Masscan::Program.sudo_scan do |masscan|
  masscan.output_format = :list
  masscan.output_file   = 'masscan.txt'

  masscan.ips   = '192.168.1.1/24'
  masscan.ports = [20,21,22,23,25,80,110,443,512,522,8080,1080]
end
```

Parse a `masscan` output file and guess the format:

```ruby
require 'masscan/output_file'

output_file = Masscan::OutputFile.new('masscan.txt')
output_file.each do |record|
  case record
  when Masscan::Status
  when Masscan::Banner
  end
end
```

Parse `masscan` Binary output files:

```ruby
output_file = Masscan::OutputFile.new('masscan.scan', format: :binary)
output_file.each do |record|
  # ...
end
```

Parse `masscan` simple list output files:

```ruby
output_file = Masscan::OutputFile.new('masscan.txt', format: :list)
output_file.each do |record|
  # ...
end
```

Parse `masscan` JSON output files:

```ruby
output_file = Masscan::OutputFile.new('masscan.json', format: :json)
output_file.each do |record|
  # ...
end
```

## Requirements

* [ruby] >= 2.0.0
* [masscan] >= 1.0.0
* [rprogram] ~> 0.3

## Install

```shell
$ gem install ruby-masscan
```

### gemspec

```ruby
gemspec.add_dependency 'ruby-masscan', '~> 0.1'
```

### Gemfile

```ruby
gem 'ruby-masscan', '~> 0.1'
```

## License

Copyright (c) 2021 Hal Brodigan

See {file:LICENSE.txt} for license information.

[masscan]: https://github.com/robertdavidgraham/masscan#readme
[ruby]: https://www.ruby-lang.org/
[rprogram]: https://github.com/postmodern/rprogram#readme
