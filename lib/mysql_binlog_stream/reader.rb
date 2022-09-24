# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::Reader
  class Reader
    # @param config [MysqlBinlogStream::Config]
    # @return [void]
    def initialize(config)
      @config = config
      @sql_executor = SQLExecutor.new(@config)
    end

    def each
      return Enumerable::Enumerator.new(self, :each) unless block_given?

      @stdout.nil? && start
      @stdout.each_line(chomp: true).reduce(nil) do |acc, elem|
        next '' if elem == "BINLOG '"
        next nil if acc.nil?
        next acc + elem if elem.length == 76

        keep = (elem != "'/*!*/;")
        str = acc + (keep ? elem : '')
        yield BinaryIO.new(Base64.decode64(str)) unless str.empty?
        keep ? '' : nil
      end
    end

    private

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
        @sql_executor.execute('SHOW BINARY LOGS').first.fetch('Log_name')
      ].compact.join(' ')
    end
  end
end
