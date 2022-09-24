# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::Config
  class Config
    # @!attribute [r] server_id
    # @return [Integer]
    attr_reader :server_id
    # @!attribute [r] host
    # @return [String]
    attr_reader :host
    # @!attribute [r] port
    # @return [Integer]
    attr_reader :port
    # @!attribute [r] user
    # @return [String]
    attr_reader :user
    # @!attribute [r] password
    # @return [String]
    attr_reader :password
    # @!attribute [r] database
    # @return [String]
    attr_reader :database
    # @!attribute [r] tables
    # @return [Array<String>]
    attr_reader :tables
    # @!attribute [r] start_timestamp
    # @return [Integer]
    attr_reader :start_timestamp

    def initialize(
      user:, password:, server_id: 111_111,
      host: '0.0.0.0',
      port: 3306,
      database: nil,
      tables: [],
      start_timestamp: nil
    )
      @server_id = server_id
      @host = host
      @port = port
      @user = user
      @password = password
      @database = database
      @tables = database ? tables : []
      @start_timestamp = start_timestamp
    end
  end
end
