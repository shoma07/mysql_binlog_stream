# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::BinaryIO
  class BinaryIO
    # @param binary [String]
    # @return [void]
    def initialize(binary)
      @io = StringIO.new(binary)
    end

    # @return [Integer]
    def remaining
      @io.length - @io.tell
    end

    # @return [Boolean]
    def eof?
      @io.eof?
    end

    # @param length [Integer]
    # @return [String]
    def read(length)
      @io.read(length)
    end

    # @param length [Integer]
    # @return [Array]
    def read_bit_array(length)
      data = read((length + 7) / 8)
      data.unpack1('b*').split('').map { |c| c == '1' }.shift(length)
    end

    # @return [Integer]
    def read_uint8
      read(1).unpack1('C')
    end

    # @return [Integer]
    def read_int8
      read(1).unpack1('c')
    end

    # @param length [Integer]
    # @return [Array]
    def read_uint8_array(length)
      read(length).bytes.to_a
    end

    # @return [Integer]
    def read_uint16
      read(2).unpack1('v')
    end

    # @return [Integer]
    def read_uint16_be
      read(2).unpack1('n')
    end

    # @return [Integer]
    def read_int16_be
      read(2).unpack1('n')
    end

    # @return [Integer]
    def read_uint24
      a, b, c = read(3).unpack('CCC')
      a + (b << 8) + (c << 16)
    end

    # @return [Integer]
    def read_uint24_be
      a, b = read(3).unpack('nC')
      (a << 8) + b
    end

    # @return [Integer]
    def read_int24_be
      a, b, c = read(3).unpack('CCC')
      if (a & 128) == 0
        (a << 16) | (b << 8) | c
      else
        (-1 << 24) | (a << 16) | (b << 8) | c
      end
    end

    # @return [Integer]
    def read_uint32
      read(4).unpack1('V')
    end

    # @return [Integer]
    def read_uint32_be
      read(4).unpack1('N')
    end

    # @return [Integer]
    def read_int32_be
      read(4).unpack1('N')
    end

    # @return [Integer]
    def read_uint40
      a, b = read(5).unpack('CV')
      a + (b << 8)
    end

    # @return [Integer]
    def read_uint40_be
      a, b = read(5).unpack('NC')
      (a << 8) + b
    end

    # @return [Integer]
    def read_uint48
      a, b, c = read(6).unpack('vvv')
      a + (b << 16) + (c << 32)
    end

    # @return [Integer]
    def read_uint56
      a, b, c = read(7).unpack('CvV')
      a + (b << 8) + (c << 24)
    end

    # @return [Integer]
    def read_uint64
      read(8).unpack1('Q<')
    end

    # @param length [Integer]
    # @return [String]
    def read_nstring(length)
      read(length)
    end

    # @param length [Integer]
    # @return [String]
    def read_nstringz(length)
      read_nstring(length).unpack1('A*')
    end

    # @param size [Integer]
    # @return [String]
    def read_lpstring(size = 1)
      read_nstring(read_uint_by_size(size))
    end

    # @param size [Integer]
    # @return [String]
    def read_lpstringz(_size = 1)
      read_lpstring.tap { read(1) }
    end

    # @return [Float]
    def read_float
      read(4).unpack1('e')
    end

    # @return [Float]
    def read_double
      read(8).unpack1('E')
    end

    # @param size [Integer]
    # @return [Integer]
    def read_uint_by_size(size)
      return read_uint8 if size == 1
      return read_uint16 if size == 2
      return read_uint24 if size == 3
      return read_uint32 if size == 4
      return read_uint40 if size == 5
      return read_uint48 if size == 6
      return read_uint56 if size == 7
      return read_uint64 if size == 8

      raise
    end

    # @param size [Integer]
    # @return [Integer]
    def read_int_be_by_size(size)
      return read_int8 if size == 1
      return read_int16_be if size == 2
      return read_int24_be if size == 3
      return read_int32_be if size == 4

      raise "read_int#{size * 8}_be not implemented"
    end

    # @return [String]
    def read_varstring
      read_nstring(read_varint)
    end

    # @param decimals [Integer]
    # @return [Integer]
    def read_frac_part(decimals)
      return 0 if decimals.zero?
      return read_uint8 * 10_000 if decimals <= 2
      return read_uint16_be * 100 if decimals <= 4
      return read_uint24_be * 100 if decimals <= 6

      raise
    end

    # @param decimals [Integer]
    # @return [Integer]
    def read_timestamp2(decimals)
      read_uint32_be + (read_frac_part(decimals) / 1_000_000)
    end

    # @return [Integer]
    def read_varint
      byte = read_uint8
      return byte if byte <= 250
      return read_uint16 if byte == 252
      return read_uint24 if byte == 253
      return read_uint64 if byte == 254

      nil
    end

    # @param value [Integer]
    # @param bits [Integer]
    # @param offset [Integer]
    # @return [Integer]
    def extract_bits(value, bits, offset)
      (value & (((1 << bits) - 1) << offset)) >> offset
    end

    # @param precision [Integer]
    # @param scale [Integer]
    # @return [BigDecimal]
    def read_newdecimal(precision, scale)
      digits_per_integer = 9
      compressed_bytes = [0, 1, 1, 2, 2, 3, 3, 4, 4, 4]
      integral = (precision - scale)
      uncomp_integral = integral / digits_per_integer
      uncomp_fractional = scale / digits_per_integer
      comp_integral = integral - (uncomp_integral * digits_per_integer)
      comp_fractional = scale - (uncomp_fractional * digits_per_integer)

      value = read_uint8
      str, mask = value & 0x80 == 0 ? ['-', -1] : ['', 0]
      @io.unget(value ^ 0x80)

      size = compressed_bytes[comp_integral]

      if size > 0
        value = read_int_be_by_size(size) ^ mask
        str << value.to_s
      end

      (1..uncomp_integral).each do
        value = read_int32_be ^ mask
        str << value.to_s
      end

      str << '.'

      (1..uncomp_fractional).each do
        value = read_int32_be ^ mask
        str << value.to_s
      end

      size = compressed_bytes[comp_fractional]

      if size > 0
        value = read_int_be_by_size(size) ^ mask
        str << value.to_s
      end

      BigDecimal(str)
    end

    # @param type [Symbol]
    # @param metadata [Hash]
    # @return [Object]
    def read_mysql_type(type, metadata)
      case type
      when :tiny
        read_uint8
      when :short
        read_uint16
      when :int24
        read_uint24
      when :long, :timestamp
        read_uint32
      when :longlong
        read_uint64
      when :float
        read_float
      when :double
        read_double
      when :var_string
        read_varstring
      when :varchar, :string
        read_lpstring(metadata[:max_length] > 255 ? 2 : 1)
      when :blob, :geometry, :json
        read_lpstring(metadata[:length_size])
      when :timestamp2
        read_timestamp2(metadata[:decimals])
      when :year
        read_uint8 + 1900
      when :date
        value = read_uint24
        format('%04i-%02i-%02i', extract_bits(value, 15, 9), extract_bits(value, 4, 5), extract_bits(value, 5, 0))
      when :time
        value = read_uint24
        format('%02i:%02i:%02i', value / 10_000, (value % 10_000) / 100, value % 100)
      when :datetime
        value = read_uint64
        date = value / 1_000_000
        time = value % 1_000_000

        format('%04i-%02i-%02i %02i:%02i:%02i', date / 10_000, (date % 10_000) / 100, date % 100, time / 10_000,
               (time % 10_000) / 100, time % 100)
      when :datetime2
        int_part = read_uint40_be
        frac_part = read_frac_part(metadata[:decimals])

        year_month = extract_bits(int_part, 17, 22)
        year = year_month / 13
        month = year_month % 13
        day = extract_bits(int_part, 5, 17)
        hour = extract_bits(int_part, 5, 12)
        minute = extract_bits(int_part, 6, 6)
        second = extract_bits(int_part, 6, 0)

        format('%04i-%02i-%02i %02i:%02i:%02i.%06i', year, month, day, hour, minute, second, frac_part)
      when :enum, :set
        read_uint_by_size(metadata[:size])
      when :bit
        read_uint_by_size((metadata[:bits] + 7) / 8)
      when :newdecimal
        read_newdecimal(metadata[:precision], metadata[:decimals])
      else
        raise UnsupportedTypeException, "Type #{type} is not supported."
      end
    end
  end
end
