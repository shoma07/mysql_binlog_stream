# frozen_string_literal: true

module MysqlBinlogStream
  module Parsers
    # MysqlBinlogStream::Parsers::HeaderParser
    class HeaderParser
      # @param [MysqlBinlogStream::BinaryIO]
      # @return [MysqlBinlogStream::Header]
      def parse(binary_io)
        timestamp = binary_io.read_uint32
        event_type_value = binary_io.read_uint8
        server_id = binary_io.read_uint32
        event_length = binary_io.read_uint32
        next_position = binary_io.read_uint32
        flags = binary_io.read_uint16

        Header.new(
          timestamp: timestamp,
          event_type: EventType.new(
            value: event_type_value,
            name: EventParsers.parser(event_type_value).event_name
          ),
          server_id: server_id,
          event_length: event_length,
          next_position: next_position,
          flags: flags,
          payload_length: 0,
          payload_end: next_position
        )
      end
    end
  end
end
