FROM ruby:3.1.2
WORKDIR /app
COPY . /app/
RUN bin/setup
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
