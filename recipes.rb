require 'cap_runner'

module Recipes
  module Capistrano
    def recipe_name
      'capistrano'
    end
    
    def setup_recipe
      puts "setting up recipe"
    end
    
    def capfile
      name.to_s / 'Capfile'
    end
    
    CAP_RE = %r{
      ^
      cap
      \s+
      ([\w:]+)
      \s+
      \#
      \s*
      (.*)
      $ 
    }x
    
    IRELEVANT_TASKS = %w{invoke shell}
    
    def recipe_tasks
      output = CapRunner.run("-Tv -f #{data_root}/#{capfile}")
      
      raise "cap command failed" unless $?.success?
      
      output.collect do |line|
        _,task,description = *line.match(CAP_RE)
        next if !task or IRELEVANT_TASKS.include?(task)

        [task,description]
      end.compact
    end
    
    def recipe_run_task
      output = CapRunner.run("-f #{data_root}/#{capfile}")
      
      # TODO need to find out what error codes we can expect back from Capistrano
    end
  end
  
  module Vlad
  end
end