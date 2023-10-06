// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import 'jquery';
import { Turbo } from "@hotwired/turbo"
window.jQuery = $;
window.$ = $;

Turbo.session.drive = false
import 'datatables'
import 'stupidtable'

import "@hotwired/turbo"
