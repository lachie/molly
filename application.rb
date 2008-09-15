module Helpers
  def parse_key(key)
    DateTime.strptime(key,"%Y%m%d%H%M%S")
  end
  
  # pinched from rails
  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    case distance_in_minutes
      when 0..1
        return (distance_in_minutes == 0) ? 'less than a minute' : '1 minute' unless include_seconds
        case distance_in_seconds
          when 0..4   then 'less than 5 seconds'
          when 5..9   then 'less than 10 seconds'
          when 10..19 then 'less than 20 seconds'
          when 20..39 then 'half a minute'
          when 40..59 then 'less than a minute'
          else             '1 minute'
        end

      when 2..44           then "#{distance_in_minutes} minutes"
      when 45..89          then 'about 1 hour'
      when 90..1439        then "about #{(distance_in_minutes.to_f / 60.0).round} hours"
      when 1440..2879      then '1 day'
      when 2880..43199     then "#{(distance_in_minutes / 1440).round} days"
      when 43200..86399    then 'about 1 month'
      when 86400..525599   then "#{(distance_in_minutes / 43200).round} months"
      when 525600..1051199 then 'about 1 year'
      else                      "over #{(distance_in_minutes / 525600).round} years"
    end
  end

  def time_ago_in_words(from_time, include_seconds = false)
    distance_of_time_in_words(from_time, Time.now, include_seconds)
  end
  
  def back_to_app
    "<a href='/apps/#{@app.name}'>&larr; #{@app.name}</a>"
  end

end

class LogLinkRenderer < MerbPaginate::LinkRenderer
  protected

  def url_options_string(page)
    app = @template.request.params[:app]
    "/#{app}?log_page=#{page}"
  end
end

class Molly < Merb::Controller
  include Helpers
  
  # def _template_location(action, type = nil, controller = controller_name)
  #     Merb.logger.debug "template location... #{action} ... #{type} ... #{controller}"
  #     "#{}#{action}.#{type}"
  #   end
  
  protected
  
  def load_app
    app_id = params[:app_id] || params[:id] || raise("no app id supplied")
    @app = App::Base.apps[app_id.to_sym] || raise("unable to find app '#{app_id}'")
    @app.user_tasks = session[:user_tasks] || []
  end

end


class Apps < Molly
  before :load_app, :exclude => [:index]

  def index
    puts "in index..."
    display @app
  end
  
  def show
    @log_page = params[:log_page] || 1
    @logs = @app.logs(@log_page)
    display @app
  end
  
  def update
    @app.update_recipe(params[:recipe])
    redirect url(:recipe_app,@app.name)
  end
  
  def recipe
    display @app
  end
  
  def edit
    puts "fC: #{}"
    self.class._form_class = Merb::Helpers::Form::Builder::ResourcefulFormWithErrors
    display @app
  end
  
  def add_task
    if(tasks = params[:task])
      user_tasks = session[:user_tasks] ||= []
      task_list = Merb::Request.unescape(tasks).gsub(/\s/,'')
      
      if(existing = user_tasks.find {|entry| entry[0] == task_list})
        existing[1] = params[:description]
      else
        user_tasks << [task_list,params[:description]]
      end
    end
    
    redirect "/#{params[:app]}"
  end

  
end


class Logs < Molly
  before :load_app
  
  def show
    @log = @app.log(params[:id])
    display @log
  end
end

class Tasks < Molly
  before :load_app

  def show
    render
  end
  
  def run
    provides :html, :json

    @app.run_task(params[:id],params[:reason])
    
    redirect url(:app_log, :app_id => @app.name, :id => @app.last_run_key)
    
    # if request.xhr?
    #       display @app
    #     else
    #       redirect '' / params[:app]
    #     end
  end
  
end