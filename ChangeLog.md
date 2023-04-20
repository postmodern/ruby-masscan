### 0.2.2 / 2023-04-20

* Corrected option definitions:
  * The `--range` option expects a IP or CIDR range value.
  * The `--exclude` option requires a value.
  * `--range`, `--exclude`, `--excludefile`, `--includefile` options may be
    repeated.
  * The --pcap-payloads` option expects a file.
  * The `--retries` option requires an argument.

### 0.2.1 / 2023-03-15

* Unescape `\\xXX` hex escaped characters in payload strings parsed from `.list`
  masscan files.

### 0.2.0 / 2021-11-30

* Replaced the `rprogram` dependency with [command_mapper].
* Fixed a typo in the mapping of the `-oJ` option flag.
* Added {Masscan::OutputFile#to_s}.

[command_mapper]: https://github.com/postmodern/command_mapper.rb#readme

### 0.1.1 / 2021-09-09

* Added missing {Masscan::Banner#ttl}.
* Fixed {Masscan::Parsers::Binary} to populate {Masscan::Banner#ttl}.
* Fixed {Masscan::Parsers::Binary#parse_status} to populate
  {Masscan::Status#reason} and {Masscan::Status#ttl}.

### 0.1.0 / 2021-08-31

* Initial release:
  * Provides a Ruby interface for running the `masscan` command.
  * Supports parsing masscan Binary, List, and JSON output files.

