module Recipes
  module Capistrano
    def recipe_name
      'capistrano'
    end
    
    def setup_recipe
      puts "setting up recipe"
    end
    
    def capfile
      name / 'Capfile'
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
      `cap -Tv -f #{data_root}/#{capfile}`.collect do |line|
        _,task,description = *line.match(CAP_RE)
        next if !task or IRELEVANT_TASKS.include?(task)

        [task,description]
      end.compact
    end
  end
  
  module Vlad
  end
end