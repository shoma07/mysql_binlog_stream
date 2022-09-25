# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::Stream
  class Stream
    include Enumerable

    # @param config [MysqlBinlogStream::Config]
    # @return [void]
    def initialize(config)
      @config = config
      @reader = Reader.new(@config)
      @parser = Parsers::Parser.new
      @context = Context.new(@config)
    end

    # @return [void]
    def each(&block)
      return ::Enumerator.new { |y| each { |row_image| y << row_image } } unless block

      @context.information_schema.update

      @reader.each do |binary_io|
        event = @parser.parse(binary_io, @context)
        next @context.update_table_map(event) if event.is_a?(TableMap)
        next unless event.is_a?(RowImage::List)

        event.row_images.each(&block)
      end
    end
  end
end
