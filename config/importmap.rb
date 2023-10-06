# Pin npm packages by running ./bin/importmap
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.7.1/dist/jquery.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true

pin 'application', preload: true

pin 'datatables'
pin 'stupidtable'

pin_all_from 'app/javascript/tylium', under: 'tylium'
