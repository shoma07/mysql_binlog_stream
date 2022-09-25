# frozen_string_literal: true

module MysqlBinlogStream
  module Parsers
    module EventParsers
      # MysqlBinlogStream::Parsers::EventParsers::TableMapEventParser
      class TableMapEventParser
        # @return [Symbol]
        def event_name
          EventType::TABLE_MAP_EVENT
        end

        # @param binary_io [MysqlBinlogStream::BinaryIO]
        # @param _header [MysqlBinlogStream::Header]
        # @param _context [MysqlBinlogStream::Context]
        # @return [MysqlBinlogStream::TableMap]
        def parse(binary_io, _header, _context)
          table_id = binary_io.read_uint48
          binary_io.read_uint16 # ignore flags
          db = binary_io.read_lpstringz
          table = binary_io.read_lpstringz
          columns_size = binary_io.read_varint
          columns_type = binary_io.read_mysql_type_names(columns_size)
          binary_io.read_varint
          columns_metadata = columns_type.map { |column_type| parse_column_metadata(binary_io, column_type) }
          columns_nullable = binary_io.read_bit_array(columns_size)
          TableMap.new(
            table_id: table_id,
            db: db,
            table: table,
            columns: columns_size.times.map.with_index do |column, index|
              TableMap::Column.new(
                index: index,
                type: columns_metadata[column]&.fetch(:type, nil) || columns_type[column],
                nullable: columns_nullable[column],
                metadata: columns_metadata[column] || {}
              )
            end
          )
        end

        private

        # @param binary_io [BinaryIO]
        # @param column_type [Symbol]
        # @return [Hash]
        def parse_column_metadata(binary_io, column_type)
          case column_type
          when :float, :double
            { size: binary_io.read_uint8 }
          when :varchar
            { max_length: binary_io.read_uint16 }
          when :bit
            bits  = binary_io.read_uint8
            bytes = binary_io.read_uint8
            { bits: (bytes * 8) + bits }
          when :newdecimal
            { precision: binary_io.read_uint8, decimals: binary_io.read_uint8 }
          when :blob, :geometry, :json
            { length_size: binary_io.read_uint8 }
          when :string, :var_string
            metadata  = (binary_io.read_uint8 << 8) + binary_io.read_uint8
            real_type = EventParsers.mysql_type(metadata >> 8)
            case real_type
            when :enum, :set
              { type: real_type, size: metadata & 0x00ff }
            else
              { max_length: (((metadata >> 4) & 0x300) ^ 0x300) + (metadata & 0x00ff) }
            end
          when :timestamp2, :datetime2, :time2
            { decimals: binary_io.read_uint8 }
          end
        end
      end
    end
  end
end
