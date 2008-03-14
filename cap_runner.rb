class CapRunner
  
  def self.run(command)
    %x{cap #{command}}
  end

end