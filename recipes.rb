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
      'Capfile'
    end
    
    def capfile_path
      data_root / capfile
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
    
    IRRELEVANT_TASKS = %w{invoke shell}
    
    def recipe_tasks
      output = CapRunner.run("-Tv -f #{capfile_path}")
      
      raise "cap command failed" unless output
      
      output.collect do |line|
        _,task,description = *line.match(CAP_RE)
        next if !task or IRRELEVANT_TASKS.include?(task)

        [task,description]
      end.compact
    end
    
    def run_task(task)
      key = Time.now.strftime("%Y%m%d%H%M%S")
      
      if thread = CapRunner.run_async("-f #{capfile_path} #{task}", :pid => pid_path(key), :log => log_path(key))
        return key
      end
      
      nil
    end
  end
  
  module Vlad
  end
end