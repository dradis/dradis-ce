# Packaging Dradis with Traveling Ruby

## Before you start

Make sure you're running these instructions in Ruby 2.2.x:

    bundle exec ruby -v

Also, whilst not strictly required you could check if there is a new version of [Traveling Ruby](http://phusion.github.io/traveling-ruby/) we can use.


## The meat and potatoes

First, make sure you're including any and all plugins that the end-user of your
package might want to include (see section 'Packaging optional plugins' below).

Then run this task to create packages for all three supported platforms:

    bundle exec rake package

Alternatively you can run individual tasks for each platform:

    bundle exec rake package:osx
    bundle exec rake package:linux:x86
    bundle exec rake package:linux:x86_64

When the task finishes you will find your packages in Dradis root as tar.gz files.

## Packaging optional plugins

We have a number of optional plugins that users may or may not include when they
run the app. We need to make sure to include all these plugins in the package,
even if they're disabled by default - it's much easier to disable plugins
after they've been included than it is to enable them when they haven't been
included.

1. Copy `Gemfile.plugins.template` to `Gemfile.plugins`. Don't worry about
   the commented-out plugins; they don't exist yet.
2. Run `bundle install`

## Beneath the hood

The above rake tasks are defined in `packaging/rake_rules.rb`. For more information
see Traveling Ruby's tutorials ([1](https://github.com/phusion/traveling-ruby/blob/master/TUTORIAL-1.md), [2](https://github.com/phusion/traveling-ruby/blob/master/TUTORIAL-2.md), [3](https://github.com/phusion/traveling-ruby/blob/master/TUTORIAL-3.md)).

The generated tar files contain a copy of the app and everything needed to run
it: Ruby 2.1.6, all required gems, and native extensions for any gems that
require them.

The version number in the names of the generated tar files is taken directly
from the version file (`lib/core/version.rb`).

## Troubleshooting

If packaging fails with a message about failing to build gem native extensions,
make sure you:

1. Are using the same version of the failing gem in both the `Gemfile` and
   `rake_rules`.
2. Are using a version of the gem which Traveling Ruby actually provides (see
   the list
   [here](https://s3-us-west-2.amazonaws.com/traveling-ruby/list.html))
3. Have added the gem to the tasks in `rake_rules.rb` so that its extensions
   get downloaded when you run the task.

At the time of writing, the gems we need that have native extensions
are `nokogiri`, `bcrypt`, `redcloth`, `sqlite3` and `mysql2`.

If the package task fails on the 'bundle install' phase, try this:

    cd ./packaging/tmp
    bundle install
    cd ../..

