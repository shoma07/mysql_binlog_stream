FROM mysql:debian

FROM ruby:3.1.2-bullseye

COPY --from=0 /usr/bin/mysqlbinlog /usr/bin/
COPY --from=0 /usr/bin/mysql /usr/bin/

RUN set -eu \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      build-essential \
      git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/gem

RUN mkdir -p lib/mysql_binlog_stream \
    && echo "module MysqlBinlogStream\n  VERSION = \"0.1.0\"\nend\n" > lib/mysql_binlog_stream/version.rb

COPY bin/setup ./bin/
COPY Gemfile Gemfile.lock mysql_binlog_stream.gemspec ./

RUN bin/setup
