# frozen_string_literal: true

require_relative 'event_parsers/unsupported_event_parser'
require_relative 'event_parsers/table_map_event_parser'
require_relative 'event_parsers/generic_rows_event_parser'

module MysqlBinlogStream
  module Parsers
    # MysqlBinlogStream::Parsers::EventParsers
    module EventParsers
      # @return [Hash]
      PARSERS = {
        0 => UnsupportedEventParser.new(:unknown),
        1 => UnsupportedEventParser.new(:start_event_v3), # (deprecated)
        2 => UnsupportedEventParser.new(:query_event),
        3 => UnsupportedEventParser.new(:stop_event),
        4 => UnsupportedEventParser.new(:rotate_event),
        5 => UnsupportedEventParser.new(:intvar_event),
        6 => UnsupportedEventParser.new(:load_event), # (deprecated)
        7 => UnsupportedEventParser.new(:slave_event), # (deprecated)
        8 => UnsupportedEventParser.new(:create_file_event), # (deprecated)
        9 => UnsupportedEventParser.new(:append_block_event),
        10 => UnsupportedEventParser.new(:exec_load_event), # (deprecated)
        11 => UnsupportedEventParser.new(:delete_file_event),
        12 => UnsupportedEventParser.new(:new_load_event), # (deprecated)
        13 => UnsupportedEventParser.new(:rand_event),
        14 => UnsupportedEventParser.new(:user_var_event),
        15 => UnsupportedEventParser.new(:format_description_event),
        16 => UnsupportedEventParser.new(:xid_event),
        17 => UnsupportedEventParser.new(:begin_load_query_event),
        18 => UnsupportedEventParser.new(:execute_load_query_event),
        19 => TableMapEventParser.new,
        20 => UnsupportedEventParser.new(:pre_ga_write_rows_event), # (deprecated)
        21 => UnsupportedEventParser.new(:pre_ga_update_rows_event), # (deprecated)
        22 => UnsupportedEventParser.new(:pre_ga_delete_rows_event), # (deprecated)
        23 => GenericRowsEventParser.new(EventType::WRITE_ROWS_EVENT_V1),
        24 => GenericRowsEventParser.new(EventType::UPDATE_ROWS_EVENT_V1),
        25 => GenericRowsEventParser.new(EventType::DELETE_ROWS_EVENT_V1),
        26 => UnsupportedEventParser.new(:incident_event),
        27 => UnsupportedEventParser.new(:heartbeat_log_event),
        28 => UnsupportedEventParser.new(:ignorable_log_event),
        29 => UnsupportedEventParser.new(:rows_query_log_event),
        30 => GenericRowsEventParser.new(EventType::WRITE_ROWS_EVENT_V2),
        31 => GenericRowsEventParser.new(EventType::UPDATE_ROWS_EVENT_V2),
        32 => GenericRowsEventParser.new(EventType::DELETE_ROWS_EVENT_V2),
        33 => UnsupportedEventParser.new(:gtid_log_event),
        34 => UnsupportedEventParser.new(:anonymous_gtid_log_event),
        35 => UnsupportedEventParser.new(:previous_gtids_log_event),
        36 => UnsupportedEventParser.new(:transaction_context_event),
        37 => UnsupportedEventParser.new(:view_change_event),
        38 => UnsupportedEventParser.new(:xa_prepare_log_event),

        50 => UnsupportedEventParser.new(:table_metadata_event) # Only in Twitter MySQL
      }.freeze
      private_constant :PARSERS

      class << self
        # @param event_type_value [Integer]
        # @return [#parse, #event_name]
        def parser(event_type_value)
          PARSERS[event_type_value] || UnsupportedEventParser.new(:"unknown_#{event_type_value}")
        end

        # @param type_value [Integer]
        # @return [Symbol]
        def mysql_type(type_value)
          ::MysqlBinlog::MYSQL_TYPES[type_value] || :"unknown_#{type_value}"
        end
      end
    end
  end
end
