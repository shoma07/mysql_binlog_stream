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
        binary_io.read_uint32 # ignore server_id
        binary_io.read_uint32 # ignore event_length
        binary_io.read_uint32 # ignore next_position
        binary_io.read_uint16 # ignore flags

        Header.new(
          timestamp: timestamp,
          event_type: EventType.new(
            value: event_type_value,
            name: EventParsers.parser(event_type_value).event_name
          )
        )
      end
    end
  end
end
