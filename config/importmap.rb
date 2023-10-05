# Pin npm packages by running ./bin/importmap

pin 'application', preload: true

pin 'datatables'
pin 'stupidtable'

pin_all_from 'app/javascript/tylium', under: 'tylium'
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
