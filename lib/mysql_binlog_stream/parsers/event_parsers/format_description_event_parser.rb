# frozen_string_literal: true

module MysqlBinlogStream
  module Parsers
    module EventParsers
      # MysqlBinlogStream::Parsers::EventParsers::FormatDescriptionEventParser
      class FormatDescriptionEventParser
        # @return [Symbol]
        def event_name
          EventType::FORMAT_DESCRIPTION_EVENT
        end

        # @param binary_io [MysqlBinlogStream::BinaryIO]
        # @param _header [MysqlBinlogStream::Header]
        # @param _context [MysqlBinlogStream::Context]
        # @return [MysqlBinlogStream::FormatDescription]
        def parse(binary_io, _header, _context)
          binlog_version = binary_io.read_uint16
          server_version = binary_io.read_nstringz(50)
          create_timestamp = binary_io.read_uint32
          header_length = binary_io.read_uint8
          FormatDescription.new(
            binlog_version: binlog_version,
            server_version: server_version,
            create_timestamp: create_timestamp,
            header_length: header_length
          )
        end
      end
    end
  end
end
