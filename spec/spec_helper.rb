$TESTING=true
require 'rubygems'
require 'merb-core'
require 'merb-core/test'

dir = File.dirname(__FILE__)

# TODO: Boot Merb, via the Test Rack adapter
Merb.start :environment => (ENV['MERB_ENV'] || 'test'),
           :adapter     => 'runner',
           :merb_root   => File.join(dir, ".." )


Spec::Runner.configure do |config|
  #config.include Merb::Test::RequestHelper
  # config.include ActiveMatchers::Matchers
  # 
  # config.include Merb::Test::Rspec::ControllerMatchers
  # 
  # config.include DefaultSpecHelper
  # config.include DefaultControllerHelper, :type => :controller
  
  config.mock_with :rr
end