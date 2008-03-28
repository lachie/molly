$TESTING=true
require 'rubygems'
require 'merb-core'
require 'merb-core/test'

dir = File.dirname(__FILE__)

# TODO: Boot Merb, via the Test Rack adapter
Merb.start :environment => (ENV['MERB_ENV'] || 'test'),
           :adapter     => 'runner',
           :merb_root   => File.join(dir, ".." )
           
           
class Hash
  def wildcard_match?(other)
    return true if other == self
    return false unless other.is_a?(Hash)
    
    return false unless self.keys.map {|k| k.to_s}.sort == other.keys.map {|k| k.to_s}.sort
    
    self.keys.each do |k|
      matched = true
      if(self[k].respond_to?(:wildcard_match?))
        matched = self[k].wildcard_match?(other[k])
      else
        matched = rr_equality_match(self[k],other[k])
      end
      return false unless matched
    end
    
    return true
  end
  
  private
  def rr_equality_match(arg1, arg2)
    arg1.respond_to?(:'__rr__original_==') ? arg1.__send__(:'__rr__original_==', arg2) : arg1 == arg2
  end
end


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