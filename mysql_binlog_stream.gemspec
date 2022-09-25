# frozen_string_literal: true

require_relative 'lib/mysql_binlog_stream/version'

Gem::Specification.new do |spec|
  spec.name = 'mysql_binlog_stream'
  spec.version = MysqlBinlogStream::VERSION
  spec.authors = ['shoma07']
  spec.email = ['23730734+shoma07@users.noreply.github.com']

  spec.summary = 'MySQL Binlog Stream'
  spec.description = 'MySQL Binlog Stream'
  spec.homepage = 'https://github.com/shoma07/mysql_binlog_stream'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.add_dependency 'mysql_binlog'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
