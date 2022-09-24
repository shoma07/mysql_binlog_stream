# frozen_string_literal: true

module MysqlBinlogStream
  module Parsers
    # MysqlBinlogStream::Parsers::Parser
    class Parser
      # @return [void]
      def initialize
        @header_parser = HeaderParser.new
      end

      # @param binary_io [MysqlBinlogStream::BinaryIO]
      # @param context [MysqlBinlogStream::Context]
      # @return [Object]
      def parse(binary_io, context)
        header = @header_parser.parse(binary_io)
        EventParsers.parser(header.event_type.value).parse(binary_io, header, context)
      end
    end
  end
end
