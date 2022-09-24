# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::Context
  class Context
    # @!attribute [r] information_schema
    # @return [MysqlBinlogStream::InformationSchema]
    attr_reader :information_schema

    # @param config [MysqlBinlogStream::Config]
    # @return [void]
    def initialize(config)
      @table_map_hash = {}
      @information_schema = InformationSchema.new(config)
      @current_timestamp = nil
      @current_record_id = 0
    end

    # @param format_description [MysqlBinlogReader::Objects::Events::FormatDescription]
    # @return [void]
    def update_format_description(format_description)
      @format_description = format_description
    end

    # @return [MysqlBinlogReader::Objects::Events::FormatDescription]
    def format_description
      raise 'format_description is not set.' unless @format_description

      @format_description
    end

    # @param table_map [MysqlBinlogReader::Objects::Events::TableMap]
    # @return [void]
    def update_table_map(table_map)
      @table_map_hash[table_map.table_id] = table_map
    end

    # @param table_id [Integer]
    # @return [MysqlBinlogReader::Objects::Events::TableMap]
    def table_map_by_table_id(table_id)
      @table_map_hash[table_id] || (raise 'table_map does not exist.')
    end

    # @param timestamp [Integer]
    # @return [Integer]
    def timestamp_record_id(timestamp)
      if @current_timestamp == timestamp
        @current_record_id += 1
      else
        @current_timestamp = timestamp
        @current_record_id = 1
      end

      @current_record_id
    end
  end
end
