# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::SQLExecutor
  class SQLExecutor
    # @param config [MysqlBinlogStream::Config]
    def initialize(config)
      @config = config
    end

    # @param sql [String]
    # @return [Array<Hash>]
    def execute(sql)
      o, e, s = Open3.capture3(
        [
          'mysql',
          "-h #{@config.host}",
          "-u #{@config.user}",
          "-P #{@config.port}",
          "--password=#{@config.password}",
          "-e '#{sql}'",
          "| sed -e 's/\t/,/g'"
        ].join(' ')
      )

      CSV.parse(o, headers: true).map(&:to_h)
    end
  end
end
