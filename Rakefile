require 'rake'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end



require 'rubygems'
require 'merb-core'

require 'merb-core/tasks/merb'
include FileUtils

# Load the basic runtime dependencies; this will include 
# any plugins and therefore plugin rake tasks.
init_env = ENV['MERB_ENV'] || 'rake'
Merb.load_dependencies(:environment => init_env)
     
# Get Merb plugins and dependencies
Merb::Plugins.rakefiles.each { |r| require r } 

# Load any app level custom rakefile extensions from lib/tasks
tasks_path = File.join(File.dirname(__FILE__), "lib", "tasks")
rake_files = Dir["#{tasks_path}/*.rake"]
rake_files.each{|rake_file| load rake_file }


desc "start runner environment"
task :merb_env do
  Merb.start_environment(:environment => init_env, :adapter => 'runner')
end


task :routes => :merb_env do
  seen = []
  unless Merb::Router.named_routes.empty?
    puts "Named Routes"
    Merb::Router.named_routes.sort_by {|name,route| name.to_s}.each do |name,route|
      puts "  #{name}: #{route}"
      seen << route
    end
  end
  puts "Anonymous Routes"
  (Merb::Router.routes - seen).each do |route|
    puts "  #{route}"
  end
end