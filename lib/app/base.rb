require 'fileutils'
require 'ostruct'
require 'pathname'

require 'pp'


module App
  class Base
    attr_reader :name, :last_run_key, :last_run_task, :app_root, :options
    attr_accessor :user_tasks
    
    def initialize(name,options)
      @name    = name
      @options = options
      
      @app_root = options[:root] || raise(ArgumentError, "no root specified for #{@name}")
      @app_path = Pathname.new(@app_root)
      
      setup_paths
      setup_recipe
    end
    
    def to_json(options={})
      instance_values.only(*%w{name last_run_task last_run_key}).to_json(options)
    end
    
    
    # recipe
    def setup_recipe
      recipe = @options[:using_recipe] || raise(ArgumentError, "no recipe specified for #{@name}")
      self.extend App::Base.recipe(recipe)
    end
    
    # paths
    
    def setup_paths
      FileUtils::mkdir_p var_root
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
    
    def recipe_path_relative
      relative_path(self.recipe_path)
    end
    
    def relative_path(path)
      Pathname.new(path).relative_path_from(@app_path).to_s
    end
    
    # logs

    def logs(page = 1)
      WillPaginate::Collection.create(page, 5) do |pager|
        logs = Dir["#{var_root}/*.log"].reverse
        
        pager.total_entries = logs.size
        
        logs = logs[pager.offset, pager.per_page]
        
        logs.map! {|d| Log.new(d, self)}
        
        pager.replace(logs)
      end
    end
    
    def log(key)
      log = Dir["#{var_root}/#{key}_*.log"].first
      Log.new(log,self)
    end
    
    @apps = {}
    def self.apps
      @apps
    end
    
    def tasks
      recipe_tasks + (user_tasks || [])
    end
    

    # git goodies
    def repo
      @git_repo ||= Grit::Repo.new(app_root)
    end
    
    
    # TODO this needs to move
    def git_log_recipe(limit=5)
      changes = []
      change = nil
      
      path = recipe_path_relative
      git_args = [{:pretty => "raw", limit => true, :numstat => true, :shortstat => true}, 'master', '--', path]
      
      repo.git.log(*git_args).each do |line|
        case line
        when /^commit (.*)$/
          changes << change = OpenStruct.new(:commit => $1, :parents => [], :log => "")
        when /^parent (.*)$/
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
          change.log << $1 if change
        end
      end
      
      changes
    end
    
    def update_recipe(new_source)
      # original_rev = repo.git.rev_list({:max_count => 1}, 'HEAD', '--', )
      # open()

      capfile = repo.status['Capfile']
      
      Dir.chdir(app_root) do
        pp repo.status
      end
      # pp repo.status.reject {|f| puts "#{f}"; f.path[/^logs/]}

      
      begin
        Dir.chdir(app_root) do
          open(recipe_path,'w') {|f| f << new_source}
          repo.add(recipe_path_relative)
          repo.commit_index('updated via interface') || raise
        end
      rescue
        puts "failed to commit or something..."
        # TODO git reset --hard HEAD^
      end

    end
    
    
    def self.create(name,options,&block)
      apps[name.to_sym] = self.new(name,options,&block)
    end
    
    # TODO make this dynamic
    def self.recipe(recipe)
      case recipe.to_sym
      when :capistrano; Recipe::Capistrano
      else
        raise "unknown recipe '#{recipe}'"
      end
    end
    
    def self.load_apps!
      ::Merb.logger.info "loading apps"
      Dir[::Merb::Config[:app_root] / '*'].each do |app_root|
        next unless File.directory?(app_root)
        
        create(File.basename(app_root), :using_recipe => detect_recipe(app_root), :root => app_root)
        
        ::Merb.logger.info "  loaded #{name}"
      end
    end
    
    def self.detect_recipe(app_root)
      case
        when File.exist?(app_root / 'Capfile')
          :capistrano
      end
    end
    
    
    self.load_apps!
  end
end