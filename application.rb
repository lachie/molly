class Foo < Merb::Controller

  def _template_location(action, type = nil, controller = controller_name)
    Merb.logger.debug "template location... #{action} ... #{type} ... #{controller}"
    "#{action}.#{type}"
  end

  def index
    puts "in index..."
    render
  end
  
  def run
    puts "running task #{params.inspect}"
    if @app = App::Base.apps[params[:app]]
      render
    else
      redirect :index
    end
  end
  
end