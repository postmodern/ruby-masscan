# ruby-masscan

[![CI](https://github.com/postmodern/ruby-masscan/actions/workflows/ruby.yml/badge.svg)](https://github.com/postmodern/ruby-masscan/actions/workflows/ruby.yml)
[![Gem Version](https://badge.fury.io/rb/ruby-masscan.svg)](https://badge.fury.io/rb/ruby-masscan)

* [Source](https://github.com/postmodern/ruby-masscan/)
* [Issues](https://github.com/postmodern/ruby-masscan/issues)
* [Documentation](http://rubydoc.info/gems/ruby-masscan/frames)

## Description

A Ruby interface to [masscan], an Internet-scale port scanner.
Allows automating masscan and parsing masscan Binary, List, and JSON output
file formats.

## Features

* Provides a [Ruby interface][Masscan::Command] for running the `masscan`
  utility.
* Supports [parsing][Masscan::OutputFile] masscan Binary, List, and JSON output
  files.

[Masscan::Command]: https://rubydoc.info/gems/ruby-masscan/Masscan/Command
[Masscan::OutputFile]: https://rubydoc.info/gems/ruby-masscan/Masscan/OutputFile

## Examples

Run `sudo masscan` from Ruby:

```ruby
require 'masscan/command'

Masscan::Command.sudo do |masscan|
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
output.format
# => :list
```

Parse `masscan` Binary output files:

```ruby
output_file = Masscan::OutputFile.new('masscan.scan', format: :binary)
output_file.each do |record|
  p record
end
```

```
#<struct Masscan::Status status=:open, protocol=:tcp, port=80, reason=[:syn, :ack], ttl=54, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-26 16:07:33 -0700, mac=nil>
#<struct Masscan::Status status=:open, protocol=:tcp, port=443, reason=[:syn, :ack], ttl=54, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-26 16:07:33 -0700, mac=nil>
#<struct Masscan::Status status=:open, protocol=:icmp, port=0, reason=[], ttl=54, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-26 16:07:33 -0700, mac=nil>
#<struct Masscan::Banner protocol=:tcp, port=443, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-26 16:07:35 -0700, app_protocol=:ssl3, payload="TLS/1.1 cipher:0xc013, www.example.org, www.example.org, example.com, example.edu, example.net, example.org, www.example.com, www.example.edu, www.example.net">
#<struct Masscan::Banner protocol=:tcp, port=443, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-26 16:07:35 -0700, app_protocol=:x509_cert, payload="MIIG1TCCBb2gAwIBAgIQD74IsIVNBXOKsMzhya/uyTANBgkqhkiG9w0BAQsFADBPMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMSkwJwYDVQQDEyBEaWdpQ2VydCBUTFMgUlNBIFNIQTI1NiAyMDIwIENBMTAeFw0yMDExMjQwMDAwMDBaFw0yMTEyMjUyMzU5NTlaMIGQMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEUMBIGA1UEBxMLTG9zIEFuZ2VsZXMxPDA6BgNVBAoTM0ludGVybmV0IENvcnBvcmF0aW9uIGZvciBBc3NpZ25lZCBOYW1lcyBhbmQgTnVtYmVyczEYMBYGA1UEAxMPd3d3LmV4YW1wbGUub3JnMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuvzuzMoKCP8Okx2zvgucA5YinrFPEK5RQP1TX7PEYUAoBO6i5hIAsIKFmFxtW2sghERilU5rdnxQcF3fEx3sY4OtY6VSBPLPhLrbKozHLrQ8ZN/rYTb+hgNUeT7NA1mP78IEkxAj4qG5tli4Jq41aCbUlCt7equGXokImhC+UY5IpQEZS0tKD4vu2ksZ04Qetp0k8jWdAvMA27W3EwgHHNeVGWbJPC0Dn7RqPw13r7hFyS5TpleywjdY1nB7ad6kcZXZbEcaFZ7ZuerA6RkPGE+PsnZRb1oFJkYoXimsuvkVFhWeHQXCGC1cuDWSrM3cpQvOzKH2vS7d15+zGls4IwIDAQABo4IDaTCCA2UwHwYDVR0jBBgwFoAUt2ui6qiqhIx56rTaD5iyxZV2ufQwHQYDVR0OBBYEFCYa+OSxsHKEztqBBtInmPvtOj0XMIGBBgNVHREEejB4gg93d3cuZXhhbXBsZS5vcmeCC2V4YW1wbGUuY29tggtleGFtcGxlLmVkdYILZXhhbXBsZS5uZXSCC2V4YW1wbGUub3Jngg93d3cuZXhhbXBsZS5jb22CD3d3dy5leGFtcGxlLmVkdYIPd3d3LmV4YW1wbGUubmV0MA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwgYsGA1UdHwSBgzCBgDA+oDygOoY4aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VExTUlNBU0hBMjU2MjAyMENBMS5jcmwwPqA8oDqGOGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNv">
#<struct Masscan::Banner protocol=:tcp, port=80, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-26 16:07:35 -0700, app_protocol=:http_server, payload="ECS (sec/97A6)">
#<struct Masscan::Banner protocol=:tcp, port=80, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-26 16:07:35 -0700, app_protocol=:html_title, payload="404 - Not Found">
#<struct Masscan::Banner protocol=:tcp, port=80, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-26 16:07:35 -0700, app_protocol=:http, payload="HTTP/1.0 404 Not Found\r\nContent-Type: text/html\r\nDate: Thu, 26 Aug 2021 23:07:35 GMT\r\nServer: ECS (sec/97A6)\r\nContent-Length: 345\r\nConnection: close\r\n\r">
```

Parse `masscan` simple list output files:

```ruby
output_file = Masscan::OutputFile.new('masscan.txt', format: :list)
output_file.each do |record|
  p record
end
```

```
#<struct Masscan::Status status=:open, protocol=:tcp, port=443, reason=nil, ttl=nil, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:47:50 -0700, mac=nil>
#<struct Masscan::Status status=:open, protocol=:tcp, port=80, reason=nil, ttl=nil, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:47:50 -0700, mac=nil>
#<struct Masscan::Status status=:open, protocol=:icmp, port=0, reason=nil, ttl=nil, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:47:50 -0700, mac=nil>
#<struct Masscan::Banner protocol=:tcp, port=443, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:47:52 -0700, app_protocol=:ssl3, payload="TLS/1.1 cipher:0xc013, www.example.org, www.example.org, example.com, example.edu, example.net, example.org, www.example.com, www.example.edu, www.example.net">
#<struct Masscan::Banner protocol=:tcp, port=443, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:47:52 -0700, app_protocol=:x509, payload="MIIG1TCCBb2gAwIBAgIQD74IsIVNBXOKsMzhya/uyTANBgkqhkiG9w0BAQsFADBPMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMSkwJwYDVQQDEyBEaWdpQ2VydCBUTFMgUlNBIFNIQTI1NiAyMDIwIENBMTAeFw0yMDExMjQwMDAwMDBaFw0yMTEyMjUyMzU5NTlaMIGQMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEUMBIGA1UEBxMLTG9zIEFuZ2VsZXMxPDA6BgNVBAoTM0ludGVybmV0IENvcnBvcmF0aW9uIGZvciBBc3NpZ25lZCBOYW1lcyBhbmQgTnVtYmVyczEYMBYGA1UEAxMPd3d3LmV4YW1wbGUub3JnMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuvzuzMoKCP8Okx2zvgucA5YinrFPEK5RQP1TX7PEYUAoBO6i5hIAsIKFmFxtW2sghERilU5rdnxQcF3fEx3sY4OtY6VSBPLPhLrbKozHLrQ8ZN/rYTb+hgNUeT7NA1mP78IEkxAj4qG5tli4Jq41aCbUlCt7equGXokImhC+UY5IpQEZS0tKD4vu2ksZ04Qetp0k8jWdAvMA27W3EwgHHNeVGWbJPC0Dn7RqPw13r7hFyS5TpleywjdY1nB7ad6kcZXZbEcaFZ7ZuerA6RkPGE+PsnZRb1oFJkYoXimsuvkVFhWeHQXCGC1cuDWSrM3cpQvOzKH2vS7d15+zGls4IwIDAQABo4IDaTCCA2UwHwYDVR0jBBgwFoAUt2ui6qiqhIx56rTaD5iyxZV2ufQwHQYDVR0OBBYEFCYa+OSxsHKEztqBBtInmPvtOj0XMIGBBgNVHREEejB4gg93d3cuZXhhbXBsZS5vcmeCC2V4YW1wbGUuY29tggtleGFtcGxlLmVkdYILZXhhbXBsZS5uZXSCC2V4YW1wbGUub3Jngg93d3cuZXhhbXBsZS5jb22CD3d3dy5leGFtcGxlLmVkdYIPd3d3LmV4YW1wbGUubmV0MA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwgYsGA1UdHwSBgzCBgDA+oDygOoY4aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VExTUlNBU0hBMjU2MjAyMENBMS5jcmwwPqA8oDqGOGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNv">
#<struct Masscan::Banner protocol=:tcp, port=80, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:47:52 -0700, app_protocol=:http_server, payload="ECS (sec/974D)">
#<struct Masscan::Banner protocol=:tcp, port=80, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:47:52 -0700, app_protocol=:html_title, payload="404 - Not Found">
#<struct Masscan::Banner protocol=:tcp, port=80, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:47:52 -0700, app_protocol=:http, payload="HTTP/1.0 404 Not Found\\x0d\\x0aContent-Type: text/html\\x0d\\x0aDate: Thu, 26 Aug 2021 06:47:52 GMT\\x0d\\x0aServer: ECS (sec/974D)\\x0d\\x0aContent-Length: 345\\x0d\\x0aConnection: close\\x0d\\x0a\\x0d">
```

Parse `masscan` JSON output files:

```ruby
output_file = Masscan::OutputFile.new('masscan.json', format: :json)
output_file.each do |record|
  p record
end
```

```
#<struct Masscan::Status status=:open, protocol=:tcp, port=80, reason=[:syn, :ack], ttl=54, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:50:21 -0700, mac=nil>
#<struct Masscan::Status status=:open, protocol=:tcp, port=443, reason=[:syn, :ack], ttl=54, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:50:21 -0700, mac=nil>
#<struct Masscan::Status status=:open, protocol=:icmp, port=0, reason=["none"], ttl=54, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:50:22 -0700, mac=nil>
#<struct Masscan::Banner protocol=:tcp, port=80, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:50:24 -0700, app_protocol=:http_server, payload="ECS (sec/974D)">
#<struct Masscan::Banner protocol=:tcp, port=80, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:50:24 -0700, app_protocol=:html_title, payload="404 - Not Found">
#<struct Masscan::Banner protocol=:tcp, port=80, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:50:24 -0700, app_protocol=:http, payload="HTTP/1.0 404 Not Found\r\nContent-Type: text/html\r\nDate: Thu, 26 Aug 2021 06:50:24 GMT\r\nServer: ECS (sec/974D)\r\nContent-Length: 345\r\nConnection: close\r\n\r">
#<struct Masscan::Banner protocol=:tcp, port=443, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:50:33 -0700, app_protocol=:ssl3, payload="TLS/1.1 cipher:0xc013, www.example.org, www.example.org, example.com, example.edu, example.net, example.org, www.example.com, www.example.edu, www.example.net">
#<struct Masscan::Banner protocol=:tcp, port=443, ip=#<IPAddr: IPv4:93.184.216.34/255.255.255.255>, timestamp=2021-08-25 23:50:33 -0700, app_protocol=:x509, payload="MIIG1TCCBb2gAwIBAgIQD74IsIVNBXOKsMzhya/uyTANBgkqhkiG9w0BAQsFADBPMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMSkwJwYDVQQDEyBEaWdpQ2VydCBUTFMgUlNBIFNIQTI1NiAyMDIwIENBMTAeFw0yMDExMjQwMDAwMDBaFw0yMTEyMjUyMzU5NTlaMIGQMQswCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEUMBIGA1UEBxMLTG9zIEFuZ2VsZXMxPDA6BgNVBAoTM0ludGVybmV0IENvcnBvcmF0aW9uIGZvciBBc3NpZ25lZCBOYW1lcyBhbmQgTnVtYmVyczEYMBYGA1UEAxMPd3d3LmV4YW1wbGUub3JnMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuvzuzMoKCP8Okx2zvgucA5YinrFPEK5RQP1TX7PEYUAoBO6i5hIAsIKFmFxtW2sghERilU5rdnxQcF3fEx3sY4OtY6VSBPLPhLrbKozHLrQ8ZN/rYTb+hgNUeT7NA1mP78IEkxAj4qG5tli4Jq41aCbUlCt7equGXokImhC+UY5IpQEZS0tKD4vu2ksZ04Qetp0k8jWdAvMA27W3EwgHHNeVGWbJPC0Dn7RqPw13r7hFyS5TpleywjdY1nB7ad6kcZXZbEcaFZ7ZuerA6RkPGE+PsnZRb1oFJkYoXimsuvkVFhWeHQXCGC1cuDWSrM3cpQvOzKH2vS7d15+zGls4IwIDAQABo4IDaTCCA2UwHwYDVR0jBBgwFoAUt2ui6qiqhIx56rTaD5iyxZV2ufQwHQYDVR0OBBYEFCYa+OSxsHKEztqBBtInmPvtOj0XMIGBBgNVHREEejB4gg93d3cuZXhhbXBsZS5vcmeCC2V4YW1wbGUuY29tggtleGFtcGxlLmVkdYILZXhhbXBsZS5uZXSCC2V4YW1wbGUub3Jngg93d3cuZXhhbXBsZS5jb22CD3d3dy5leGFtcGxlLmVkdYIPd3d3LmV4YW1wbGUubmV0MA4GA1UdDwEB/wQEAwIFoDAdBgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwgYsGA1UdHwSBgzCBgDA+oDygOoY4aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0VExTUlNBU0hBMjU2MjAyMENBMS5jcmwwPqA8oDqGOGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNv">
```

## Requirements

* [ruby] >= 2.0.0
* [masscan] >= 1.0.0
* [command_mapper] ~> 0.1

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
[command_mapper]: https://github.com/postmodern/command_mapper.rb#readme
