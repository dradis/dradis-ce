ARG RUBY_VERSION=3.4.6
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

WORKDIR /workspace

# Ensure binding is always 0.0.0.0
# Binds the server to all IP addresses of the container, so it can be accessed from outside the container.
ENV BINDING="0.0.0.0"

# Mise shims are normally only added to PATH by .bashrc's `mise activate`, which
# doesn't run in non-login shells. Add them directly so `docker exec ... bundle ...`
# resolves the same binaries without needing to spawn a login shell.
ENV PATH="/home/vscode/.local/share/mise/shims:${PATH}"

EXPOSE 3000
