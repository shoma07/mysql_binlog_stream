# frozen_string_literal: true

require 'optparse'
require 'optparse/time'
require 'io/console'

module MysqlBinlogStream
  # MysqlBinlogStream::CLI
  class CLI
    # @param args [Array<String>]
    # @return [void]
    def initialize(args)
      @args = args
      @option = {
        server_id: 111_111,
        host: '0.0.0.0',
        port: 3_306,
        user: nil,
        password: nil,
        database: nil,
        tables: [],
        start_timestamp: nil,
        pretty: false
      }
      @parser = optparser
    end

    # @return [void]
    def run
      optparser.parse(@args)
      return unless valid_option

      enter_password
      MysqlBinlogStream::Stream.new(generate_config).each do |event|
        event.to_h.then { |hash| $stdout.puts(@option[:pretty] ? JSON.pretty_generate(hash) : JSON.generate(hash)) }
      end
    rescue Interrupt
      $stdout.puts('Bye!')
    end

    private

    # @return [MysqlBinlogStream::Config]
    def generate_config
      MysqlBinlogStream::Config.new(
        server_id: @option.fetch(:server_id),
        host: @option.fetch(:host),
        port: @option.fetch(:port),
        user: @option.fetch(:user),
        password: @option.fetch(:password),
        database: @option.fetch(:database),
        tables: @option.fetch(:tables),
        start_timestamp: @option.fetch(:start_timestamp)
      )
    end

    # @return [OptionParser]
    def optparser # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
      OptionParser.new do |opt| # rubocop:todo Metrics/BlockLength
        opt.banner = 'Usage: mysql-binlog-stream [options]'

        opt.on('--server-id [VAL]', Integer, "default #{@option[:server_id]}") do |v|
          @option[:server_id] = v
        end
        opt.on('--host [VAL]', String, "default #{@option[:host]}") do |v|
          @option[:host] = v
        end
        opt.on('--port [VAL]', Integer, "default #{@option[:port]}") do |v|
          @option[:port] = v
        end
        opt.on('--user VAL', String) do |v|
          @option[:user] = v
        end
        opt.on('--password VAL', String) do |v|
          @option[:password] = v
        end
        opt.on('--database [VAL]', String) do |v|
          @option[:database] = v
        end
        opt.on('--tables [VAL]', Array) do |v|
          @option[:tables] = v
        end
        opt.on('--start-timestamp [VAL]', Integer) do |v|
          @option[:start_timestamp] = v
        end
        opt.on('--start-datetime [VAL]', Time) do |v|
          @option[:start_timestamp] = v.to_i
        end
        opt.on('--pretty') do |v|
          @option[:pretty] = v
        end
      end
    end

    # @return [void]
    def valid_option
      return true unless @option[:user].nil?

      $stdout.puts(@parser.help)

      false
    end

    # @return [void]
    def enter_password
      return unless @option[:password].nil?

      $stdout.print('Enter password: ')
      @option[:password] = $stdin.noecho(&:gets).chomp
      $stdout.print("\n")
    end
  end
end
