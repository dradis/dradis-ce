ARG RUBY_VERSION=3.4.6
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /dradis

# Install dependencies for Ruby build and gems
RUN apt-get update -qq && \
apt-get install --no-install-recommends -y curl git libjemalloc2 libvips sqlite3 && \
apt-get install -y redis-server && \
rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set Rails environment
ARG RAILS_ENV="production"
ARG BUNDLE_WITHOUT="development sandbox test"
ENV RAILS_ENV=$RAILS_ENV \
    RAILS_SERVE_STATIC_FILES="enabled" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT=$BUNDLE_WITHOUT

# Throw-away build stage to reduce size of final image
FROM base AS build

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git pkg-config libyaml-dev && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy files needed to run `bundle install` to build layer
# engines/ is needed to resolve built-in engines in Gemfile
# version.rb is needed to resolve engine versions in .gemspec
COPY Gemfile Gemfile.lock ./
COPY engines ./engines
COPY lib/dradis/ce/version.rb ./lib/dradis/ce/version.rb

# Install application gems
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

COPY . .

# Copy sample files
COPY config/database.yml.template config/database.yml
COPY config/smtp.yml.template config/smtp.yml

# Preparing application folders
RUN mkdir -p app/views/tmp \
    attachments \
    config/shared \
    storage \
    templates

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /dradis /dradis

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails app/views/tmp attachments config/shared db log storage tmp templates
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/dradis/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 80 443
CMD ["./bin/boot"]
