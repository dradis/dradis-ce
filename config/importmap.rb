# Pin npm packages by running ./bin/importmap
pin '@hotwired/turbo-rails', to: '@hotwired--turbo-rails.js', preload: true
pin '@hotwired/turbo', to: '@hotwired--turbo.js', preload: true # @7.3.0
pin '@rails/actioncable/src', to: '@rails--actioncable--src.js', preload: true # @7.1.1

pin 'application', preload: true

pin 'datatables'
pin 'stupidtable'
