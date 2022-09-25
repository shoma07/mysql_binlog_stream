# frozen_string_literal: true

RSpec.describe MysqlBinlogStream::Stream do
  let(:config) do
    MysqlBinlogStream::Config.new(
      user: 'root',
      password: 'root',
      server_id: 111_111,
      host: 'db',
      port: 3306,
      database: 'chat'
      # start_timestamp: Time.now.to_i
    )
  end

  let(:sql_executor) { MysqlBinlogStream::SQLExecutor.new(config) }

  let(:stream) { described_class.new(config).each }

  let(:io) { StringIO.new }

  context 'when insert' do
    subject(:row_image) { JSON.parse(io.tap(&:rewind).read, symbolize_names: true) }

    before do
      sql_executor.execute('INSERT INTO messages (content) VALUES ("hello");')
      stream.each do |row_image| # rubocop:todo Lint/UnreachableLoop
        io.tap(&:rewind).write(JSON.generate(row_image.to_h))
        break
      end
    end

    it do # rubocop:todo RSpec/MultipleExpectations
      expect(row_image[:metadata][:db]).to eq 'chat'
      expect(row_image[:metadata][:table]).to eq 'messages'
      expect(row_image[:metadata][:operation]).to eq 'insert'
    end
  end
end
