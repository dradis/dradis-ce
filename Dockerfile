# We're sticking to non-slim version: https://hub.docker.com/_/ruby/
FROM --platform=linux/amd64 ruby:3.4.4

WORKDIR /app

ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    RAILS_SERVE_STATIC_FILES="enabled"

# Copying dradis-ce app
COPY . .

# Copying sample files
COPY config/database.yml.template config/database.yml
COPY config/smtp.yml.template config/smtp.yml

# Preparing application folders
RUN mkdir -p attachments/
RUN mkdir -p config/shared/
RUN mkdir -p templates/

# Is this only needed because M1 build?
RUN bundle config build.ffi --enable-libffi-alloc

# Installing dependencies
RUN gem update --system
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
# CMD ["./bin/rails", "server"]
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
