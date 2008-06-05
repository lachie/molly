require 'fileutils'

module App
  class Base
    attr_reader :name, :last_run_key, :last_run_task
    attr_accessor :user_tasks
    
    def initialize(name,&block)
      @name = name
      instance_eval(&block)
      
      setup_paths
      setup_recipe
    end
    
    def to_json(options={})
      instance_values.only(*%w{name last_run_task last_run_key}).to_json(options)
    end
    
    def using_recipe(recipe)
      self.extend App::Base.recipe(recipe)
    end
    
    # paths
    
    def setup_paths
      FileUtils::mkdir_p app_root
      FileUtils::mkdir_p var_root
    end
    
    def app_root
      ::Merb.root_path('data',name.to_s)
    end
    
    def var_root
      File.join(app_root,"logs")
    end
    
    def pid_path(key)
      File.join(var_root,"#{key}.pid")
    end
    
    def log_path(key,task)
      File.join(var_root,"#{key}_#{task}.log")
    end
    
    def status_path(key)
      File.join(var_root,"#{key}.status")
    end
        
    def logs
      Dir["#{var_root}/*.log"].collect {|d| Log.new(d,self)}
    end
    
    def log(key)
      log = Dir["#{var_root}/#{key}_*.log"].first
      Log.new(log,self)
    end
    
    def self.apps
      @apps ||= {}
    end
    
    def tasks
      recipe_tasks + (user_tasks || [])
    end
    
    def self.create(kind,name,&block)
      klass = class_from_name(kind)
      apps[name.to_sym] = klass.new(name,&block)
    end
    
    # TODO make this dynamic for subclasses
    def self.class_from_name(name)
      case name.to_sym
      when :rails; App::Rails
      when :merb ; App::Merb
      else
        raise "unknown app type '#{name}'"
      end
    end
    
    # TODO make this dynamic
    def self.recipe(recipe)
      case recipe.to_sym
      when :capistrano; Recipes::Capistrano
      else
        raise "unknown recipe '#{recipe}'"
      end
    end
  end
end

class Object
  # loads an app definition block
  def app(kind,name,&block)
    App::Base.create(kind,name,&block)
  end
end