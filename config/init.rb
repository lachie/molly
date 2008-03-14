Merb.push_path(:view, Merb.root / "views")
Merb::Router.prepare do |r|
  r.match('/').to(:controller => 'foo', :action =>'index')
  r.default_routes
end

require 'application'

dependency 'merb-haml'


Merb::Config.use { |c|
  c[:environment]         = 'production',
  c[:framework]           = {},
  c[:log_level]           = 'debug',
  c[:use_mutex]           = false,
  c[:session_store]       = 'cookie',
  c[:session_id_key]      = '_session_id',
  c[:session_secret_key]  = '104fdd3bd7908ee608938e5df9d9b2e9a73ff384',
  c[:exception_details]   = true,
  c[:reload_classes]      = true,
  c[:reload_time]         = 0.5
}


require 'pp'
require 'app'
require 'recipes'
require Merb.root_path('config','apps')

pp App::Base.apps