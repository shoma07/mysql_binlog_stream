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
    # @param server_id [Integer]
    # @param event_length [Integer]
    # @param next_position [Integer]
    # @param flags [Integer]
    # @param payload_length [Integer]
    # @param payload_end [Integer]
    # @return [void]
    def initialize(
      timestamp:,
      event_type:,
      server_id:,
      event_length:,
      next_position:,
      flags:,
      payload_length:,
      payload_end:
    )
      @timestamp = timestamp
      @event_type = event_type
      @server_id = server_id
      @event_length = event_length
      @next_position = next_position
      @flags = flags
      @payload_length = payload_length
      @payload_end = payload_end
    end
  end
end
