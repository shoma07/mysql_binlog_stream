# frozen_string_literal: true

module MysqlBinlogStream
  module Parsers
    module EventParsers
      # MysqlBinlogStream::Parsers::EventParsers::UnsupportedEventParser
      class UnsupportedEventParser
        # @!attribute [r] event_name
        # @return [Symbol]
        attr_reader :event_name

        # @param event_name
        # @return [void]
        def initialize(event_name)
          @event_name = event_name
        end

        # @param _binary_io [MysqlBinlogStream::BinaryIO]
        # @param _header [MysqlBinlogStream::Header]
        # @param _context [MysqlBinlogStream::Context]
        # @return [nil]
        def parse(_binary_io, _header, _context); end
      end
    end
  end
end
