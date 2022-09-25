# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::Reader
  class Reader
    # MysqlBinlogStream::Reader::LogFileNotFoundError
    class LogFileNotFoundError < StandardError; end

    # @param config [MysqlBinlogStream::Config]
    # @return [void]
    def initialize(config)
      @config = config
      @sql_executor = SQLExecutor.new(@config)
    end

    def each(&block)
      return Enumerable::Enumerator.new(self, :each) unless block

      @stdout.nil? && start
      @stdout.each_line(chomp: true).reduce(nil) do |acc, elem|
        process_line(acc, elem, &block)
      end
    end

    private

    # @param acc [String, nil]
    # @param elem [String]
    # @yieldparam [MysqlBinlogStream::BinaryIO]
    # @yieldreturn [void]
    # @return [String, nil]
    def process_line(acc, elem)
      return '' if elem == "BINLOG '"
      return nil if acc.nil?
      return acc + elem if elem.length == 76

      keep = (elem != "'/*!*/;")
      str = acc + (keep ? elem : '')
      yield(generate_binary_io(str)) unless str.empty?
      keep ? '' : nil
    end

    # @param str [String]
    # @return [MysqlBinlogStream::BinaryIO]
    def generate_binary_io(str)
      BinaryIO.new(Base64.decode64(str))
    end

    # @return [void]
    def start
      stdin, stdout, stderr, wait_thr = Open3.popen3(mysqlbinlog_command)
      stdin.close
      @stdout = stdout
      @stderr = stderr
      @wait_thr = wait_thr
    end

    # @return [String]
    def mysqlbinlog_command
      [
        'mysqlbinlog',
        '--force-read',
        "--connection-server-id=#{@config.server_id}",
        '--read-from-remote-server',
        "--host=#{@config.host}",
        "--port=#{@config.port}",
        "--user=#{@config.user}",
        "--password=#{@config.password}",
        @config.database ? "--database=#{@config.database}" : nil,
        @config.start_timestamp ? "--start-datetime=#{Time.at(@config.start_timestamp).strftime('%FT%T')}" : nil,
        '--stop-never',
        log_name
      ].compact.join(' ')
    end

    # @return [String]
    # @raise [MysqlBinlogStream::Reader::LogFileNotFoundError]
    def log_name
      @sql_executor.execute('SHOW BINARY LOGS').first&.fetch('Log_name') || (raise LogFileNotFoundError)
    end
  end
end
