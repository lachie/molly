class CapRunner
   
  def self.run(command)
    output = %x{cap #{command}}
    
     $?.success? ? output : nil
  end
  
  def self.build_async_command(command,options={})
    command = "cap #{command}"
    
    if log = options[:log]
      command = "#{command} > #{log} 2>&1"
    end
    
    puts command
    
    command
  end
  
  def self.run_async(command,options={})
    command = build_async_command(command,options)

    pid = fork {puts "o hai #{$$}"; system command}
    
    if pid and pidfile = options[:pid]
      File.open(pidfile,'w') {|f| f << pid}
    end
    
    pid
  end
end