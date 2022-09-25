# frozen_string_literal: true

module MysqlBinlogStream
  module Parsers
    module EventParsers
      # MysqlBinlogStream::Parsers::EventParsers::GenericRowsEventParser
      class GenericRowsEventParser
        CHECKSUM_LENGTH = 4
        private_constant :CHECKSUM_LENGTH

        # @!attribute [r] event_name
        # @return [Symbol]
        attr_reader :event_name

        # @param event_name
        # @return [void]
        def initialize(event_name)
          @event_name = event_name
        end

        # @param binary_io [MysqlBinlogStream::BinaryIO]
        # @param header [MysqlBinlogStream::Header]
        # @param context [MysqlBinlogStream::Context]
        # @return [Hash]
        def parse(binary_io, header, context)
          table_id = binary_io.read_uint48
          table_map = context.table_map_by_table_id(table_id)
          information_schema = context.information_schema
          binary_io.read_uint16 # ignore flags
          skip_variable_header(binary_io)
          columns = binary_io.read_varint
          before_used = (binary_io.read_bit_array(columns) if parse_before?)
          after_used = (binary_io.read_bit_array(columns) if parse_after?)
          row_images = loop.reduce([]) do |acc, _elem|
            break acc if binary_io.remaining <= CHECKSUM_LENGTH

            before = (parse_row_image(binary_io, information_schema, table_map, before_used) if before_used)
            after = (parse_row_image(binary_io, information_schema, table_map, after_used) if after_used)
            acc + [
              RowImage.new(
                metadata: RowImage::Metadata.new(
                  db: table_map.db,
                  table: table_map.table,
                  operation: operation,
                  timestamp: header.timestamp,
                  timestamp_record_id: context.timestamp_record_id(header.timestamp)
                ),
                before: (before if after),
                data: after || before
              )
            ]
          end

          RowImage::List.new(row_images: row_images)
        end

        private

        # @return [Boolean]
        def contains_variable_header?
          event_name.to_s.end_with?('v2')
        end

        # @return [Boolean]
        def parse_before?
          event_name.to_s.start_with?(/u|d/)
        end

        # @return [Boolean]
        def parse_after?
          event_name.to_s.start_with?(/u|w/)
        end

        # @param binary_io [BinaryIO]
        # @param information_schema [MysqlBinlogReader::InformationSchema]
        # @param table_map [MysqlBinlogReader::Objects::TableMap]
        # @param columns [Array]
        # @return [Hash]
        def parse_row_image(binary_io, information_schema, table_map, columns_used)
          columns_null = binary_io.read_bit_array(columns_used.size)
          table_map.columns.to_h do |column|
            column_name = information_schema.column_name(table_map.db, table_map.table, column.index)
            next [column_name, nil] if !columns_used[column.index] || columns_null[column.index]

            [column_name, binary_io.read_mysql_type(column.type, column.metadata)]
          end
        end

        # @param binary_io [BinaryIO]
        # @return [void]
        def skip_variable_header(binary_io)
          return unless contains_variable_header?

          length = binary_io.read_uint16 - 2
          binary_io.read(length) if length.positive?
        end

        # @return [String]
        def operation
          event_name_str = event_name.to_s
          return 'insert' if event_name_str.start_with?('w')
          return 'delete' if event_name_str.start_with?('d')

          'update'
        end
      end
    end
  end
end
