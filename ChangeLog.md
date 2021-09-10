### 0.1.1 / 2021-09-09

* Added missing {Masscan::Banner#ttl}.
* Fixed {Masscan::Parsers::Binary} to populate {Masscan::Banner#ttl}.
* Fixed {Masscan::Parsers::Binary#parse_status} to populate
  {Masscan::Status#reason} and {Masscan::Status#ttl}.

### 0.1.0 / 2021-08-31

* Initial release:
  * Provides a Ruby interface for running the `masscan` command.
  * Supports parsing masscan Binary, List, and JSON output files.

