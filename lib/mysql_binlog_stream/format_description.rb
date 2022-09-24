# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::FormatDescription
  class FormatDescription
    # @!attribute [r] binlog_version
    # @return [Integer]
    attr_reader :binlog_version

    # @param binlog_version [Integer]
    # @param server_version [String]
    # @param create_timestamp [Integer]
    # @param header_length [Integer]
    # @return [void]
    def initialize(
      binlog_version:,
      server_version:,
      create_timestamp:,
      header_length:
    )
      @binlog_version = binlog_version
      @server_version = server_version
      @create_timestamp = create_timestamp
      @header_length = header_length
    end
  end
end
