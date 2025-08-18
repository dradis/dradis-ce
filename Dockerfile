ARG RUBY_VERSION=3.4.4
# We're sticking to non-slim version: https://hub.docker.com/_/ruby/
FROM ruby:${RUBY_VERSION}

WORKDIR /app

# Copy files needed for bundle install to first layer to leverage Docker cache
# (lib/ and engines/ are needed for bundle install to succeed)
COPY Gemfile Gemfile.lock ./
COPY engines/dradis-api ./engines/dradis-api
COPY lib ./lib

ENV RAILS_ENV="production" \
    RAILS_SERVE_STATIC_FILES="enabled" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" 

RUN bundle install

COPY . .

# Copying sample files
COPY config/database.yml.template config/database.yml
COPY config/smtp.yml.template config/smtp.yml

# Preparing application folders
RUN mkdir -p attachments \
    config/shared \
    storage \
    templates

RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails attachments config/shared db log storage tmp templates

USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 443 80
CMD ["./bin/thrust", "./bin/rails", "server"]
