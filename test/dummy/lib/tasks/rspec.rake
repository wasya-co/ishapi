
def puts! a, b=''
  puts "+++ +++ ${b}:"
  puts a.inspect
end

namespace :rspec do

  desc 'spec - default'
  task spec: :environment do
    puts 'Getting the factories...'
    spec = Gem::Specification.find_by_name 'ish_models'
    `rm -f spec/factories/ish_models_factories.rb`
    `cp -v #{spec.gem_dir}/spec/factories/ish_models_factories.rb spec/factories/`

    puts 'Running the spec...'
    Rake::Task[:spec].invoke
  end

end
