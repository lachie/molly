require 'cap_runner'

# Recipes for deploying apps
# Recipes mix in to App::Base subclasses, using the 'using' macro
#
# === Required methods
# Recipe modules need to provide
#
# setup_recipe   do any init that the recipe might like to do
# recipe_name    the human name of the recipe
# recipe_tasks   a list of tasks provided by the recipe
# run_task       run one of the tasks provided by the recipe
# recipe_source  returns the source of the recipe file

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
      app_root / capfile
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
      key = @last_run_key = Time.now.utc.strftime("%Y%m%d%H%M%S")
      @last_run_task = task
      
      if thread = CapRunner.run_async("-f #{capfile_path} #{task}", :pid => pid_path(key), :log => log_path(key,task), :status => status_path(key))
        return true
      end
      
      false
    end
    
    def recipe_source
      File.read(capfile_path)
    end
  end
  
  module Vlad
  end
end