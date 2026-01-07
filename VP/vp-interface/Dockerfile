# Switch to Debian-based slim image to avoid all musl/glibc compatibility issues
# Precompiled gems like commonmarker and eventmachine load natively without shims
FROM ruby:3.3-slim

# Set locale
ENV LANG=C.UTF-8 \
    LANGUAGE=C.UTF-8 \
    LC_ALL=C.UTF-8

# Install runtime and build dependencies
# Runtime: libraries needed at run time
# Build: headers/compilers needed only for gem compilation
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libxml2 \
        libxslt1.1 \
        libyaml-0-2 \
        libraptor2-0 && \
    apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        libxml2-dev \
        libxslt1-dev \
        libyaml-dev \
        libraptor2-dev && \
    bundle config set --global build.nokogiri '--use-system-libraries' && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /server

# Copy Gemfile + lock + gemspec for better caching
COPY Gemfile Gemfile.lock vp-interface.gemspec /server/

# Install gems
RUN bundle install --jobs $(nproc) --retry 5

# Remove build dependencies to shrink image
RUN apt-get purge -y --auto-remove \
        build-essential \
        pkg-config \
        libxml2-dev \
        libxslt1-dev \
        libyaml-dev \
        libraptor2-dev && \
    rm -rf /var/lib/apt/lists/*

# Copy application code
COPY . /server/vp-interface
WORKDIR /server/vp-interface

# Your app start command
# CMD ["bundle", "exec", "thin", "start", "-p", "3000"]  # or ruby app.rb, etc.