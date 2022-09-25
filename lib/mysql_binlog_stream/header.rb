# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::Header
  class Header
    # @!attribute [r] timestamp
    # @return [Integer]
    attr_reader :timestamp
    # @!attribute [r] event_type
    # @return [EventType]
    attr_reader :event_type

    # @param timestamp [Integer]
    # @param event_type [EventType]
    # @return [void]
    def initialize(
      timestamp:,
      event_type:
    )
      @timestamp = timestamp
      @event_type = event_type
    end
  end
end
