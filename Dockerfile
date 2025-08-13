ARG RUBY_VERSION=3.4.4
# We're sticking to non-slim version: https://hub.docker.com/_/ruby/
FROM ruby:${RUBY_VERSION}

# Define acceptable build arguments (must be set AFTER the FROM line):
ARG SSL_CERT_DIR=/etc/ssl/dradis.local
ARG SSL_CERT_FILE=${SSL_CERT_DIR}/bundle.dradis.local.crt
ARG SSL_KEY_FILE=${SSL_CERT_DIR}/dradis.local.key

WORKDIR /app

ENV RAILS_ENV="production" \
    RAILS_SERVE_STATIC_FILES="enabled" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    SSL_CERT_DIR=${SSL_CERT_DIR} \
    SSL_CERT_FILE=${SSL_CERT_FILE} \
    SSL_KEY_FILE=${SSL_KEY_FILE}

# Copying dradis-ce app
COPY . .

# Copying sample files
COPY config/database.yml.template config/database.yml
COPY config/smtp.yml.template config/smtp.yml

# Preparing application folders
RUN mkdir -p attachments/
RUN mkdir -p config/shared/
RUN mkdir -p templates/
RUN mkdir -p tmp/pids/
RUN mkdir -p $SSL_CERT_DIR

# Installing dependencies
RUN bundle install

RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails attachments config/shared db log tmp templates && \
    chown -R rails:rails $SSL_CERT_DIR && \
    chmod 700 $SSL_CERT_DIR

USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
