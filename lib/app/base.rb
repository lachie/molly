require 'fileutils'
require 'ostruct'

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
    
    # logs
        
    def logs(page = 1)
      Dir["#{var_root}/*.log"] \
        .collect {|d| Log.new(d, self)} \
        .reverse \
        .paginate(:per_page => 5, :page => page)
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
    
    
    # commit c4555717a9f6002a05d806e8fe284d767de55e96
    #     tree 8b0ff1534ec6bb2cddb17b5753dd1c26e181dfe1
    #     parent ce31f0c8853f3899e1d3c909551d2caf16c6866d
    #     author Lachie Cox <lachie@smartbomb.com.au> 1205469982 +1100
    #     committer Lachie Cox <lachie@smartbomb.com.au> 1205469982 +1100
    # 
    #         added error checking to recipe_tasks
    # 
    #     12  0 data/welcome/Capfile
    #      1 files changed, 12 insertions(+), 0 deletions(-)
    #     
    
    # git
    def git_log_recipe(limit=5)
      changes = []
      change = OpenStruct.new
      Git.git.log( {:pretty => "raw", limit => true, :numstat => true, :shortstat => true}, 'master', '--', self.recipe_path).each do |line|
        case line
        when /^commit (.*)$/
          changes << change = OpenStruct.new(:commit => $1)
        when /^parent (.*)$/
          change.parents ||= []
          change.parents << $1
        when /^author/
          # nothing
        when /^committer .*? <[^>]+> (\d+)/
          change.time = Time.at(Integer($1))
        when /^(\d+)\t(\d+)\t(.+)$/
          change.insertions = Integer($1)
          change.deletions  = Integer($2)
          change.path       = $3
        when /^\s+(.+)$/
          change.log ||= ""
          change.log += $1
        end
      end
      
      changes
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