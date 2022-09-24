# frozen_string_literal: true

RSpec.describe MysqlBinlogStream do
  it 'has a version number' do
    expect(MysqlBinlogStream::VERSION).not_to be_nil
  end
end
