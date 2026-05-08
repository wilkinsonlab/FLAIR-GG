# Ruby 3.2: json-ld / LinkedData libraries clash with the json gem changes in 3.3
FROM ruby:3.2-slim

ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install runtime libs and build deps in one layer.
# Build deps (headers/compilers) are purged after gem compilation to keep the image lean.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libxml2 \
        libxslt1.1 \
        libyaml-0-2 \
        libraptor2-0 \
        build-essential \
        pkg-config \
        libxml2-dev \
        libxslt1-dev \
        libyaml-dev \
        libraptor2-dev && \
    bundle config set --global build.nokogiri '--use-system-libraries' && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /server/vp-interface

# Copy dependency manifests first for better layer caching —
# bundle install only re-runs when these files change.
COPY Gemfile Gemfile.lock vp-interface.gemspec ./

RUN bundle install --jobs $(nproc) --retry 5 && \
    apt-get purge -y --auto-remove \
        build-essential \
        pkg-config \
        libxml2-dev \
        libxslt1-dev \
        libyaml-dev \
        libraptor2-dev

# Copy application code after gems are installed
COPY . .

EXPOSE 4567

CMD ["bundle", "exec", "ruby", "run.rb"]
