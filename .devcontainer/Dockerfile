ARG RUBY_VERSION=3.4.6
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

WORKDIR /workspace

# Ensure binding is always 0.0.0.0
# Binds the server to all IP addresses of the container, so it can be accessed from outside the container.
ENV BINDING="0.0.0.0"

EXPOSE 3000
