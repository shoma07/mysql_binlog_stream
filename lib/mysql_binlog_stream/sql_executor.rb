# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::SQLExecutor
  class SQLExecutor
    # MysqlBinlogStream::SQLExecutor::Error
    class Error < StandardError; end

    # @param config [MysqlBinlogStream::Config]
    # @return [void]
    def initialize(config)
      @config = config
    end

    # @param sql [String]
    # @return [Array<Hash>]
    def execute(sql)
      output, error, status = Open3.capture3(
        [
          "mysql -h #{@config.host} -u #{@config.user} -P #{@config.port} --password=#{@config.password} -e '#{sql}'",
          "sed -e 's/\t/,/g'"
        ].join(' | ')
      )
      raise Error, error unless status.success?

      CSV.parse(output, headers: true).map(&:to_h)
    end
  end
end
