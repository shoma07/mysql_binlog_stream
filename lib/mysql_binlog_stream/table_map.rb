# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::TableMap
  class TableMap
    # MysqlBinlogStream::TableMap::Column
    class Column
      # @!attribute [r] index
      # @return [Integer]
      attr_reader :index
      # @!attribute [r] type
      # @return [Symbol]
      attr_reader :type
      # @!attribute [r] nullable
      # @return [Boolean]
      attr_reader :nullable
      # @!attribute [r] metadata
      # @return [Hash]
      attr_reader :metadata

      # @param index [Integer]
      # @param type [Symbol]
      # @param nullable [Boolean]
      # @param metadata [Hash]
      # @return [void]
      def initialize(index:, type:, nullable:, metadata:)
        @index = index
        @type = type
        @nullable = nullable
        @metadata = metadata
      end
    end

    # @!attribute [r] table_id
    # @return [Integer]
    attr_reader :table_id
    # @!attribute [r] db
    # @return [String]
    attr_reader :db
    # @!attribute [r] table
    # @return [String]
    attr_reader :table
    # @!attribute [r] columns
    # @return [Array<MysqlBinlogStream::TableMap::Column>]
    attr_reader :columns

    # @param table_id [Integer]
    # @param db [String]
    # @param table [String]
    # @param columns [Array<MysqlBinlogStream::TableMap::Column>]
    # @return [void]
    def initialize(table_id:, db:, table:, columns:)
      @table_id = table_id
      @db = db
      @table = table
      @columns = columns
    end
  end
end
