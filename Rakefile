namespace :molly do
  desc "add a recipe"
  task :add
end

namespace :git do
  task :push
  task :pull
end


require 'rake'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end