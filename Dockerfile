# ─────────────────────────────────────────────────────────────
# Redmine 4.2.7 on Ruby 2.7 with PostgreSQL
# ─────────────────────────────────────────────────────────────
FROM ruby:2.7.8

ENV REDMINE_VERSION=4.2.7
ENV RAILS_ENV=production

# 1. OS packages: add libpq-dev, remove MariaDB libs
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libpq-dev         \
        imagemagick       \
        ghostscript       \
        curl              \
        libxml2-dev       \
        libxslt1-dev      \
        libffi-dev        \
        nodejs            \
        git               \
        build-essential &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# 2. Bundler
RUN gem install bundler -v 2.2.33 --no-document

# 3. Download & unpack Redmine
WORKDIR /usr/src
RUN curl -fsSL "https://www.redmine.org/releases/redmine-${REDMINE_VERSION}.tar.gz" -o redmine.tar.gz && \
    tar -xzf redmine.tar.gz && rm redmine.tar.gz && \
    mv "redmine-${REDMINE_VERSION}" redmine

WORKDIR /usr/src/redmine

# 4. Extra gem needed by some plugins
RUN echo "gem 'blankslate', '~> 2.1.2.4'" >> Gemfile

# 5. Copy plugins/themes (if any) **before** bundle install
COPY plugins/ plugins/
COPY themes/  public/themes/

# 6. Install Ruby gems (pg is already in Gemfile)
RUN bundle config set --local without 'development test' && \
    bundle install --jobs 4

# 7. Expose port & entrypoint
EXPOSE 3000
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]

# 8. Default command – Puma/WEBrick
CMD ["rails", "server", "-b", "0.0.0.0"]
