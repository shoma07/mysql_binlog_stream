# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::RowImage
  class RowImage
    # MysqlBinlogStream::RowImage::List
    class List
      # @!attribute [r] row_images
      # @return [Array<MysqlBinlogStream::RowImage>]
      attr_reader :row_images

      # @param row_images [Array<MysqlBinlogStream::RowImage>]
      # @return [void]
      def initialize(row_images:)
        @row_images = row_images
      end
    end

    # MysqlBinlogStream::RowImage::Metadata
    class Metadata
      # @!attribute [r] db
      # @return [String]
      attr_reader :db
      # @!attribute [r] table
      # @return [String]
      attr_reader :table
      # @!attribute [r] operation
      # @return [String]
      attr_reader :operation
      # @!attribute [r] timestamp
      # @return [Integer]
      attr_reader :timestamp
      # @!attribute [r] timestamp_record_id
      # @return [Integer]
      attr_reader :timestamp_record_id

      # @param db [String]
      # @param table [String]
      # @param timestamp [Integer]
      # @param timestamp_record_id [Integer]
      # @return [void]
      def initialize(
        db:,
        table:,
        operation:,
        timestamp:,
        timestamp_record_id:
      )
        @db = db
        @table = table
        @operation = operation
        @timestamp = timestamp
        @timestamp_record_id = timestamp_record_id
      end

      # @return [Hash]
      def to_h
        {
          db: @db,
          table: @table,
          operation: @operation,
          timestamp: @timestamp,
          timestamp_record_id: @timestamp_record_id
        }
      end
    end

    # @!attribute [r] metadata
    # @return [Metadata]
    attr_reader :metadata
    # @!attribute [r] before
    # @return [Hash]
    attr_reader :before
    # @!attribute [r] data
    # @return [Hash]
    attr_reader :data

    # @param metadata [MysqlBinlogStream::Metadata]
    # @param before [Hash, nil]
    # @param data [Hash]
    # @return [void]
    def initialize(
      metadata:,
      before:,
      data:
    )
      @metadata = metadata
      @before = before
      @data = data
    end

    # @return [Hash]
    def to_h
      {
        metadata: @metadata.to_h,
        before: @before,
        data: @data
      }.compact
    end
  end
end
