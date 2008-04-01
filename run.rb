require 'rubygems'
require 'merb-core'
require 'config/init'
require 'pp'

puts "yeah #{$$}"

app = App::Base.apps[:welcome]
pp app.recipe_tasks
pp app.run_task :deploy

puts "going to wait for all the threads"
Thread.list.each do |t|
  next if t == Thread.current
  t.join
end


# puts Process.wait
puts "done"