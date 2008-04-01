module App
  class Base
    attr_reader :name
    
    
    def self.clean_pid(pid)
      pid = pid.to_s
      Dir[::Merb.root_path('data','**','*.pid')].each do |pidfile|
        puts "pid #{pidfile} ... #{File.read(pidfile).chomp} ... #{pid}"
        if pid == File.read(pidfile).chomp
          puts "cleaning pid #{pid}"
          File.unlink(pidfile)
        end
      end
    end
    
    def initialize(name,&block)
      @name = name
      instance_eval(&block)
      
      setup_recipe
    end
    
    def using_recipe(recipe)
      self.extend App::Base.recipe(recipe)
    end
    
    def data_root
      ::Merb.root_path('data',name.to_s)
    end
    
    def pid_path(key)
      File.join(data_root,"#{key}.pid")
    end
    def log_path(key)
      File.join(data_root,"#{key}.log")
    end
    
    def self.apps
      @apps ||= {}
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