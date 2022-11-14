# MysqlBinlogStream

## Dependencies

- [mysqlbinlog - Utility for Processing Binary Log Files](https://dev.mysql.com/doc/refman/8.0/en/mysqlbinlog.html)
- mysql client

## Installation

### Using `specific_install`

```sh
$ gem install specific_install
$ gem specific_install https://github.com/shoma07/mysql_binlog_stream.git
```

### Using `bundler`

Add this line to your application's Gemfile:

```ruby
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gem 'mysql_binlog_stream', github: 'shoma07/mysql_binlog_stream'
```

And then execute:

```sh
$ bundle install
```

## Usage

```sh
# command-line
# mysql-binlog-stream --help
$ mysql-binlog-stream --host 0.0.0.0 --port 3306 --user user
Enter password:
```

```ruby
require 'mysql_binlog_stream'

config = MysqlBinlogStream::Config.new(
  host: '0.0.0.0',
  port: 3306,
  user: 'user',
  password: 'password',
  database: 'database'
)

MysqlBinlogStream::Stream.new(config).each do |event|
  pp event.to_h
end
```

## References

- [jeremycole/mysql_binlog](https://github.com/jeremycole/mysql_binlog)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mysql_binlog_stream. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/shoma07/mysql_binlog_stream/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the MysqlBinlogStream project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shoma07/mysql_binlog_stream/blob/main/CODE_OF_CONDUCT.md).
