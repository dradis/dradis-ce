# Pin npm packages by running ./bin/importmap
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true

pin 'application', preload: true

pin 'datatables'
pin 'stupidtable'

pin_all_from 'app/javascript/tylium', under: 'tylium'
