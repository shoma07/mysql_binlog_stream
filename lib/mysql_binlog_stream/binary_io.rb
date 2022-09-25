# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::BinaryIO
  class BinaryIO < DelegateClass(::MysqlBinlog::BinlogFieldParser)
    # MysqlBinlogStream::BinaryIO::Binlog
    class Binlog
      # @!attribute [r] reader
      # @return [StringIO]
      attr_reader :reader

      # @param reader [StringIO]
      # @return [void]
      def initialize(reader)
        @reader = reader
      end
    end

    private_constant :Binlog

    # @param binary [String]
    # @return [void]
    def initialize(binary)
      super(::MysqlBinlog::BinlogFieldParser.new(Binlog.new(StringIO.new(binary))))
    end

    # @return [Integer]
    def remaining
      reader.length - reader.tell
    end

    # @param length [Integer]
    # @return [String]
    def read(length)
      reader.read(length)
    end

    # @param length [Integer]
    # @return [Array<Symbol>]
    def read_mysql_type_names(length)
      read_uint8_array(length).map { |value| ::MysqlBinlog::MYSQL_TYPES[value] || :"unknown_#{value}" }
    end

    private :binlog, :reader
  end
end
