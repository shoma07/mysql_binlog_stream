# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::EventType
  class EventType
    TABLE_MAP_EVENT = :table_map_event
    WRITE_ROWS_EVENT_V1 = :write_rows_event_v1
    UPDATE_ROWS_EVENT_V1 = :update_rows_event_v1
    DELETE_ROWS_EVENT_V1 = :delete_rows_event_v1
    WRITE_ROWS_EVENT_V2 = :write_rows_event_v2
    UPDATE_ROWS_EVENT_V2 = :update_rows_event_v2
    DELETE_ROWS_EVENT_V2 = :delete_rows_event_v2
    GENERIC_ROWS_EVENTS = Set.new(
      [
        WRITE_ROWS_EVENT_V1,
        UPDATE_ROWS_EVENT_V1,
        DELETE_ROWS_EVENT_V1,
        WRITE_ROWS_EVENT_V2,
        UPDATE_ROWS_EVENT_V2,
        DELETE_ROWS_EVENT_V2
      ]
    ).freeze
    private_constant :GENERIC_ROWS_EVENTS

    # @!attribute [r] value
    # @return [Integer]
    attr_reader :value
    # @!attribute [r] name
    # @return [String]
    attr_reader :name

    # @param value [Integer]
    # @param name [String]
    # @return [void]
    def initialize(value:, name:)
      @value = value
      @name = name
    end

    # @return [Boolean]
    def generic_rows_event?
      GENERIC_ROWS_EVENTS.include?(name)
    end

    # @return [Hash]
    def to_h
      {
        value: @value,
        name: @name
      }
    end
  end
end
