namespace :db do
  namespace :seed do
    desc 'Load the seed data from dradis-sandbox engine'
    task dradis_sandbox: :environment do
      Dradis::Sandbox::Engine.load_seed
    end
  end
end

# Enhance the app's main db:seed task
Rake::Task['db:seed'].enhance(['db:seed:dradis_sandbox'])
