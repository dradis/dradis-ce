# For Bundler.with_clean_env
require 'bundler/setup'
require 'dradis/ce'

# require "sqlite3"

PACKAGE_NAME = 'dradis'
VERSION = Dradis::CE.version
TRAVELING_RUBY_VERSION = '20180126-2.4.1'
TRAVELING_RUBY_PATH = Rails.root.join('../traveling-ruby')

# Must match Gemfile:
BCRYPT_VERSION       = '3.1.10'
MYSQL2_VERSION       = '0.3.18'
NOKOGIRI_VERSION     = '1.8.1'
REDCLOTH_VERSION     = '4.3.1'
SQLITE3_VERSION      = '1.3.13'
RINKU_VERSION        = '2.0.4'
THERUBYRACER_VERSION = '0.12.3'

namespace :assets do
  namespace :precompile do
    desc 'Shorthand to run assets:precompile in production mode'
    task :production do
      system('rake assets:precompile RAILS_ENV=production')
    end
  end
end


desc 'Package your app'
task :package => ['package:linux:x86', 'package:linux:x86_64', 'package:osx']

namespace :package do
  namespace :linux do
    desc 'Package your app for Linux x86'
    task :x86 => [:bundle_install,
      'assets:precompile:production',
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-bcrypt-#{BCRYPT_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-mysql2-#{MYSQL2_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-RedCloth-#{REDCLOTH_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-sqlite3-#{SQLITE3_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-rinku-#{RINKU_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-therubyracer-#{THERUBYRACER_VERSION}.tar.gz"
    ] do
      create_package('linux-x86')
    end

    desc 'Package your app for Linux x86_64'
    task :x86_64 => [:bundle_install,
      'assets:precompile:production',
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-bcrypt-#{BCRYPT_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-mysql2-#{MYSQL2_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-RedCloth-#{REDCLOTH_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-sqlite3-#{SQLITE3_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-rinku-#{RINKU_VERSION}.tar.gz",
      "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-therubyracer-#{THERUBYRACER_VERSION}.tar.gz"
    ] do
      create_package('linux-x86_64')
    end
  end

  desc 'Package your app for OS X'
  task :osx => [:bundle_install,
    'assets:precompile:production',
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-bcrypt-#{BCRYPT_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-mysql2-#{MYSQL2_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-nokogiri-#{NOKOGIRI_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-RedCloth-#{REDCLOTH_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-sqlite3-#{SQLITE3_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-rinku-#{RINKU_VERSION}.tar.gz",
    "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-therubyracer-#{THERUBYRACER_VERSION}.tar.gz"
  ] do
    create_package('osx')
  end

 desc 'Install gems to local directory'
  task :bundle_install do
    puts "\nRunning package:bundle_install..."
    if RUBY_VERSION !~ /^2\.4\.\1/
      abort "You can only 'bundle install' using Ruby 2.4.1, because that's what Traveling Ruby uses."
    end

    puts "\nRecreating tmp directory..."
    sh 'rm -rf packaging/tmp'
    sh 'mkdir -p packaging/tmp'

    puts '\nInstalling gems...'
    sh 'cp Gemfile Gemfile.lock packaging/tmp'
    sh 'cp Gemfile.plugins.template packaging/tmp/Gemfile.plugins'

    puts "\nAdjusting relative repo dirs..."

    # We want to replace ../dradis-* with ../../../dradis-*
    # regexp = "s/\\.\\.\\/dradis-/\\.\\.\\/\\.\\.\\/\\.\\.\\/dradis-/g"

    # We want to replace "path: '../dradis-*'" with "github: 'dradis/dradis-*'"
    # regexp = "s/path: \'\\.\\./github: \'dradis/g"

    # We want to replace "path: 'engines/*'" with "path: '../../engines-*'"
    engines_regexp = "s/'engines\\//'\\.\\.\\/\\.\\.\\/engines\\//g"

    # If any gems specified with 'path' have names (i.e. filepaths) that end in
    # a trailing '/', that / will still be present after 'path' is changed to
    # 'github' and will create an invalid github URL. So remove it:
    # trailing_slash_regex = "/github:/s/\\/'$/'/"

    ['Gemfile', 'Gemfile.lock', 'Gemfile.plugins'].each do |gemfile|
      path = "packaging/tmp/#{gemfile}"
      if RbConfig::CONFIG['host_os'] =~ /darwin/
        # sh "sed -i '' -- \"#{regexp}\" #{path}"
        # sh "sed -i '' -- \"#{trailing_slash_regex}\" #{path}"
        sh "sed -i '' -- \"#{engines_regexp}\" #{path}"
      else
        # sh "sed -i -- \"#{regexp}\" #{path}"
        # sh "sed -i - \"#{trailing_slash_regex}\" #{path}"
        sh "sed -i -- \"#{engines_regexp}\" #{path}"
      end
    end

    puts "\nCommenting unnecessary gems..."
    if RbConfig::CONFIG['host_os'] =~ /darwin/
      #sh "sed -i '' -- \"s/gem \\'therubyracer/\\# gem \\'therubyracer/g\" packaging/tmp/Gemfile"
      sh "sed -i '' -- \"s/gem \\'unicorn/\\# gem \\'unicorn/g\" packaging/tmp/Gemfile"
      # remove 'group: :development' from sqlite3 line
      sh "sed -i '' -- \"s/1\.3\.10\\', group: :development/1\.3\.10\\'/g\" Gemfile"
    else
      #sh "sed -i -- \"s/gem \'therubyracer/# gem \'therubyracer/g\" packaging/tmp/Gemfile"
      sh "sed -i -- \"s/gem \'unicorn/# gem \'unicorn/g\" packaging/tmp/Gemfile"
      # remove 'group: :development' from sqlite3 line
      sh "sed -i -- \"s/1\\.3\\.10\\', group: :development/1\\.3\\.10\\'/g\" Gemfile"
    end

    Bundler.with_clean_env do
      # sh "cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 NOKOGIRI_USE_SYSTEM_LIBRARIES=1 bundle install --path ../vendor --without development test"
      sh 'cd packaging/tmp && env BUNDLE_IGNORE_CONFIG=1 bundle install --path ../vendor --without development test'
    end

    puts "\nCleaning up cache and native extensions..."
    sh 'rm -rf packaging/vendor/*/*/cache/*'
    sh 'rm -rf packaging/vendor/ruby/*/extensions'
    sh "find packaging/vendor/ruby/*/gems -name '*.so' | xargs rm -f"
    sh "find packaging/vendor/ruby/*/gems -name '*.bundle' | xargs rm -f"
    sh "find packaging/vendor/ruby/*/gems -name '*.o' | xargs rm -f"
  end

end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86.tar.gz" do
  copy_runtime('linux-x86')
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64.tar.gz" do
  copy_runtime('linux-x86_64')
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx.tar.gz" do
  copy_runtime('osx')
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-bcrypt-#{BCRYPT_VERSION}.tar.gz" do
  copy_native_extension('linux-x86', "bcrypt-#{BCRYPT_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-bcrypt-#{BCRYPT_VERSION}.tar.gz" do
  copy_native_extension('linux-x86_64', "bcrypt-#{BCRYPT_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-bcrypt-#{BCRYPT_VERSION}.tar.gz" do
  copy_native_extension('osx', "bcrypt-#{BCRYPT_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-mysql2-#{MYSQL2_VERSION}.tar.gz" do
  copy_native_extension('linux-x86', "mysql2-#{MYSQL2_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-mysql2-#{MYSQL2_VERSION}.tar.gz" do
  copy_native_extension('linux-x86_64', "mysql2-#{MYSQL2_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-mysql2-#{MYSQL2_VERSION}.tar.gz" do
  copy_native_extension('osx', "mysql2-#{MYSQL2_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-nokogiri-#{NOKOGIRI_VERSION}.tar.gz" do
  copy_native_extension('linux-x86', "nokogiri-#{NOKOGIRI_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-nokogiri-#{NOKOGIRI_VERSION}.tar.gz" do
  copy_native_extension('linux-x86_64', "nokogiri-#{NOKOGIRI_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-nokogiri-#{NOKOGIRI_VERSION}.tar.gz" do
  copy_native_extension('osx', "nokogiri-#{NOKOGIRI_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-RedCloth-#{REDCLOTH_VERSION}.tar.gz" do
  copy_native_extension('linux-x86', "RedCloth-#{REDCLOTH_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-RedCloth-#{REDCLOTH_VERSION}.tar.gz" do
  copy_native_extension('linux-x86_64', "RedCloth-#{REDCLOTH_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-RedCloth-#{REDCLOTH_VERSION}.tar.gz" do
  copy_native_extension('osx', "RedCloth-#{REDCLOTH_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-sqlite3-#{SQLITE3_VERSION}.tar.gz" do
  copy_native_extension('linux-x86', "sqlite3-#{SQLITE3_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-sqlite3-#{SQLITE3_VERSION}.tar.gz" do
  copy_native_extension('linux-x86_64', "sqlite3-#{SQLITE3_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-sqlite3-#{SQLITE3_VERSION}.tar.gz" do
  copy_native_extension('osx', "sqlite3-#{SQLITE3_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-rinku-#{RINKU_VERSION}.tar.gz" do
  copy_native_extension('linux-x86', "rinku-#{RINKU_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-rinku-#{RINKU_VERSION}.tar.gz" do
  copy_native_extension('linux-x86_64', "rinku-#{RINKU_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-rinku-#{RINKU_VERSION}.tar.gz" do
  copy_native_extension('osx', "rinku-#{RINKU_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86-therubyracer-#{THERUBYRACER_VERSION}.tar.gz" do
  copy_native_extension('linux-x86', "therubyracer-#{THERUBYRACER_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-linux-x86_64-therubyracer-#{THERUBYRACER_VERSION}.tar.gz" do
  copy_native_extension('linux-x86_64', "therubyracer-#{THERUBYRACER_VERSION}")
end

file "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-osx-therubyracer-#{THERUBYRACER_VERSION}.tar.gz" do
  copy_native_extension('osx', "therubyracer-#{THERUBYRACER_VERSION}")
end

def create_package(target)
  puts "\nCreating package #{ target }..."

  package_dir = "#{PACKAGE_NAME}-#{VERSION}-#{target}"

  puts "\nRecreating #{package_dir} directory..."
  sh "rm -rf #{package_dir}"
  sh "mkdir #{package_dir}"
  sh "mkdir -p #{package_dir}/lib/app"

  puts "\nCopying app..."
  sh "cp -r config.ru Rakefile Thorfile bin app config lib public db vendor engines #{package_dir}/lib/app/"
  sh "cp config/secrets.yml.template #{package_dir}/lib/app/config/secrets.yml"
  sh "rm -rf #{package_dir}/lib/app/vendor/cache #{package_dir}/lib/app/db/*.sqlite3"


  puts "\nPreparing database..."
  sh 'cp config/database.yml.template config/database.yml'
  sh 'RAILS_ENV=production rake db:setup'
  sh "cp db/production.sqlite3 #{package_dir}/lib/app/db/"

  # db = SQLite3::Database.new "#{package_dir}/lib/app/db/production.sqlite3"
  # table = "dradis_configurations"
  # # These configuration options contain hardcoded file paths that will almost
  # # definitely not be the same on the user's machine... so delete them and
  # # make the user generate their own.
  # db.execute "DELETE FROM #{table} WHERE name='admin:paths:templates:reports';"
  # db.execute "DELETE FROM #{table} WHERE name='admin:paths:templates:plugins';"
  # # Reset the password:
  # db.execute "UPDATE #{table} SET value='improvable_dradis' WHERE name='password';"

  puts "\nCopying ruby..."
  sh "mkdir #{package_dir}/lib/ruby"
  sh "tar -xzf packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz -C #{package_dir}/lib/ruby"

  puts "\nCopying wrapper scripts and vendor files..."
  sh "cp packaging/wrapper-common.sh #{package_dir}/lib"
  sh "cp packaging/dradis-webapp packaging/dradis-worker #{package_dir}"
  sh "cp -pR packaging/vendor #{package_dir}/lib/"

  puts "\nCopying gems..."

  # Traveling Ruby moves all 'top-level' Rails directories into a new
  # directory in the package called 'app'. (So there'll be 'app/app', 'app/lib',
  # etc). Before adding the app's Gemfile to the package, we need to change
  # the relative path of the 'engines' gems so Bundler can find them under the
  # new app/engines directory:
  engines_regexp = 's/\\.\\.\\/\\.\\.\\/engines/\\..\\/app\\/engines/g'
  if RbConfig::CONFIG['host_os'] =~ /darwin/
    sh "sed -i '' -- \"#{engines_regexp}\" packaging/tmp/Gemfile"
  else
    sh "sed -i -- \"#{engines_regexp}\" packaging/tmp/Gemfile"
  end

  sh "cp packaging/tmp/Gemfile packaging/tmp/Gemfile.plugins packaging/tmp/Gemfile.lock #{package_dir}/lib/vendor/"

  sh "mkdir #{package_dir}/lib/vendor/.bundle"
  sh "cp packaging/bundler-config #{package_dir}/lib/vendor/.bundle/config"

  sh "cp README.md LICENSE.txt CHANGELOG #{package_dir}"

  if RbConfig::CONFIG['host_os'] =~ /darwin/
    sh "sed -i '' -- \"s/config\.force_ssl = true/config\.force_ssl = false/g\" #{package_dir}/lib/app/config/environments/production.rb"
  else
    sh "sed -i -- \"s/config\.force_ssl = true/config\.force_ssl = false/g\" #{package_dir}/lib/app/config/environments/production.rb"
  end

  [
    "bcrypt-#{BCRYPT_VERSION}",
    "nokogiri-#{NOKOGIRI_VERSION}",
    "mysql2-#{MYSQL2_VERSION}",
    "RedCloth-#{REDCLOTH_VERSION}",
    "sqlite3-#{SQLITE3_VERSION}",
    "rinku-#{RINKU_VERSION}",
    "therubyracer-#{THERUBYRACER_VERSION}"
  ].each do |gem|
    sh 'tar -xzf ' +
       "packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem}.tar.gz"+
       " -C #{package_dir}/lib/vendor/ruby"
  end

  unless ENV['DIR_ONLY']
    puts "\nPacking..."
    sh "tar -czf #{package_dir}.tar.gz #{package_dir}"
    sh "rm -rf #{package_dir}"
  end
end

def download_runtime(target)
  puts "\nDownloading runtime #{ target }"
  sh 'cd packaging && curl -L -O --fail ' +
    "http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz"
end

def download_native_extension(target, gem_name_and_version)
  puts "\nDownloading native extension #{ target }"
  sh "curl -L --fail -o packaging/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem_name_and_version}.tar.gz " +
    "http://d6r77u77i8pq3.cloudfront.net/releases/traveling-ruby-gems-#{TRAVELING_RUBY_VERSION}-#{target}/#{gem_name_and_version}.tar.gz"
end

def copy_runtime(target)
  puts "\nCopying runtime #{ target }"
  folder = target =~ /^linux/ ? 'linux' : 'osx'
  sh 'cd packaging && ' +
     "cp #{TRAVELING_RUBY_PATH}/#{folder}/traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}.tar.gz ."
end

def copy_native_extension(target, gem_name_and_version)
  puts "\nCopying native extension #{ target }"
  folder = target =~ /^linux/ ? 'linux' : 'osx'
  sh 'cd packaging && ' +
     "cp #{TRAVELING_RUBY_PATH}/#{folder}/traveling-ruby-gems-#{TRAVELING_RUBY_VERSION}-#{target}/#{gem_name_and_version}.tar.gz " +
     "traveling-ruby-#{TRAVELING_RUBY_VERSION}-#{target}-#{gem_name_and_version}.tar.gz"
end
