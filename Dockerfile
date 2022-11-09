FROM ruby:3.1.2
WORKDIR /app
# Copying dradis-ce app
COPY . /app/
# Copying sample files
COPY config/database.yml.template config/database.yml
COPY config/secrets.yml.template config/secrets.yml
COPY config/smtp.yml.template config/smtp.yml
# Preparing templates folder
RUN mkdir -p /app/templates
# Installing dependencies
RUN bundle install
# Preparing database
RUN bin/rails db:prepare
RUN bin/rails db:seed
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
