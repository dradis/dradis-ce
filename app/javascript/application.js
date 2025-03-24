// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails'

import 'datatables'
import 'stupidtable'

import 'controllers'

Turbo.session.drive = false; // Do not enable Turbo Drive globally
