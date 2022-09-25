# frozen_string_literal: true

# MysqlSetup
module MysqlSetup
  class << self
    # @return [void]
    def execute
      config = MysqlBinlogStream::Config.new(
        user: 'root', password: 'root', server_id: 111_111, host: 'db', port: 3306
      )
      executor = MysqlBinlogStream::SQLExecutor.new(config)
      executor.execute('DROP DATABASE IF EXISTS chat')
      executor.execute('CREATE DATABASE chat')
      executor.execute(<<~SQL.tr("\n", ' '))
        CREATE TABLE chat.messages (
          id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY,
          content VARCHAR(255) NOT NULL,
          created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
          updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        );
      SQL
    end
  end
end
