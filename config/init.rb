Merb.push_path(:view        , Merb.root / "views")
Merb.push_path(:application , Merb.root / 'application.rb')
Merb.push_path(:lib         , Merb.root / 'lib')
Merb.push_path(:config      , Merb.root / 'config', 'apps.rb')

Merb.push_path(:log,          Merb.log_path, nil)
Merb.push_path(:public,       Merb.root_path("public"), nil)
Merb.push_path(:stylesheet,   Merb.dir_for(:public) / "stylesheets", nil)
Merb.push_path(:javascript,   Merb.dir_for(:public) / "javascripts", nil)
Merb.push_path(:image,        Merb.dir_for(:public) / "images", nil)

Merb::Router.prepare do |r|
  r.resources(:apps, :member => {:recipe => :get}) do |app|
    app.resources(:logs)
    app.resources(:tasks, :member => {:run => :get})
  end



  r.match('/:app/log/:key').to(:controller => 'apps', :action => 'log')
  
  # r.match('/:id').to(:controller => 'apps', :action => 'show')
  # r.match('/:id/:command').to(:controller => 'apps', :action => ':command')
  
  
  # r.match('/:app/:command/:task').to(:controller => 'apps', :action => ':command')
  r.match(%r[^/:app/:command/(.+)]).to(:controller => 'apps', :action => ':command', :task => '[3]')
  
  
  r.match('/').to(:controller => 'apps', :action =>'index')
  
  r.default_routes
end

# require 'application'

use_test :rspec
dependencies 'merb-haml', 'merb-assets', 'activesupport', 'merb_paginate', 'merb_helpers'


gem 'mojombo-grit'
require 'grit'

Grit.debug = true


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
  
  
  c[:cap] = '/usr/bin/cap'  
  c[:app_root] = File.expand_path(Merb.root + "/../molly_apps")
}

Merb::BootLoader.after_app_loads do
  
end