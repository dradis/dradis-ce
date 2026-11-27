// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import '@hotwired/turbo-rails'

import 'datatables'
import 'stupidtable'

import 'controllers'

Turbo.session.drive = false; // Do not enable Turbo Drive globally

// Event delegation, registered once, as the Turbo handbook recommends. <html> is
// never replaced, so this also covers tooltips added later by frames and streams.
new bootstrap.Tooltip(document.documentElement, {
  selector: '[data-bs-toggle="tooltip"]',
});
