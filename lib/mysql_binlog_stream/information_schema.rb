# frozen_string_literal: true

module MysqlBinlogStream
  # MysqlBinlogStream::InformationSchema
  class InformationSchema
    # @param config [MysqlBinlogStream::Config]
    # @return [void]
    def initialize(config)
      @config = config
      @sql_executor = SQLExecutor.new(@config)
      @columns_by_table = {}
      @loaded = false
    end

    # @param database [String]
    # @param table [String]
    # @param index [Integer]
    # @return [String]
    def column_name(database, table, index)
      @columns_by_table.fetch("#{database}.#{table}.#{index}", index.to_s)
    end

    # @return [void]
    def update
      return if @loaded

      @loaded = true
      @columns_by_table = @sql_executor.execute(sql)
                                       .group_by { |hash| "#{hash['table_schema']}.#{hash['table_name']}" }
                                       .transform_values do |values|
                                         values.map.with_index do |value, index|
                                           ["#{value['table_schema']}.#{value['table_name']}.#{index}",
                                            value['column_name']]
                                         end
                                       end.values.flatten(1).to_h
    end

    private

    # @return [String]
    def sql
      condition = [
        @config.database.nil? ? nil : "table_schema = \"#{@config.database}\"",
        @config.tables.empty? ? nil : "table_name in (#{@config.tables.map { |table| "\"#{table}\"" }.join(', ')})"
      ].compact.join('AND ')
      [
        'SELECT table_schema, table_name, column_name FROM information_schema.columns',
        condition.empty? ? nil : "WHERE #{condition}"
      ].compact.join(' ')
    end
  end
end
