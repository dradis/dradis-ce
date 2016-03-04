#!/bin/bash
set -e

# Figure out where this script is located.
SELFDIR="`dirname \"$0\"`"
SELFDIR="`cd \"$SELFDIR\" && pwd`"

# Tell Bundler where the Gemfile and gems are.
export BUNDLE_GEMFILE="$SELFDIR/lib/vendor/Gemfile"
unset BUNDLE_IGNORE_CONFIG

cd "$SELFDIR/lib/app"

export PATH="$SELFDIR/lib/ruby/bin:$SELFDIR/lib/vendor/ruby/2.1.0/bin:$PATH"
if ! [ -e .secret_key_base ];then
    hexdump -n 64 -v -e '/1 "%02X"' /dev/urandom > .secret_key_base
fi
export SECRET_KEY_BASE="$(cat .secret_key_base)"
export PACKAGING=1 # prevent errors from missing development/test dependencies
if [ "$RAILS_ENV" == "" ];then
    export RAILS_ENV=production
fi
