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
    "<a href='/#{@app.name}'>&larr; #{@app.name}</a>"
  end

end


class Apps < Merb::Controller
  include Helpers
  before :load_app, :exclude => [:index]
  
  def _template_location(action, type = nil, controller = controller_name)
    Merb.logger.debug "template location... #{action} ... #{type} ... #{controller}"
    "#{action}.#{type}"
  end

  def index
    puts "in index..."
    display @app
  end
  
  def show
    display @app
  end
  
  def recipe
    Merb.logger.debug "foobar, recipe #{@app}"
    render
  end
  
  def run
    provides :html, :json

    @app.run_task(params[:task])
    
    if request.xhr?
      display @app
    else
      redirect '' / params[:app]
    end
  end
  
  def log
    if key = params[:key]
      @log = @app.log(key)
      render
    else
      redirect "/#{params[:app]}"
    end
  end
  
  protected
  
  def load_app
    if params[:app].blank?
      raise "application name wasn't specified"
    end
    
    @app = App::Base.apps[params[:app].to_sym]
    
    unless @app
      raise "unable to find app '#{params[:app]}'"
    end
  end
  
end