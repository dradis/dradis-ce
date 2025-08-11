# Accept build arguments and set default values
# BUNDLE_WITHOUT can be overridden at build time to build a development image
# e.g. docker build --build-arg BUNDLE_WITHOUT="""
ARG BUNDLE_WITHOUT=development:test
ARG RUBY_VERSION=3.4.4

# We're sticking to non-slim version: https://hub.docker.com/_/ruby/
FROM ruby:${RUBY_VERSION}

WORKDIR /app

ENV BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT=${BUNDLE_WITHOUT}

# Copying dradis-ce app
COPY . .

# Copying sample files
COPY config/database.yml.template config/database.yml
COPY config/smtp.yml.template config/smtp.yml

# Preparing application folders
RUN mkdir -p attachments/
RUN mkdir -p config/shared/
RUN mkdir -p templates/

# Installing dependencies
RUN bundle install

RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails attachments config/shared db log tmp templates
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server"]
