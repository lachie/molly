require 'rubygems'
require 'merb-core'
require 'config/init'
require 'pp'

puts "yeah #{$$}"

app = App::Base.apps[:welcome]
pp app.recipe_tasks
pp app.run_task :deploy


puts Process.wait
puts "done"