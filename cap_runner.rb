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
  
  def self.run_asyncx(command,options={})
    command = build_async_command(command,options)

    pid = fork {puts "o hai #{$$}"; system command}
    
    if pid and pidfile = options[:pid]
      File.open(pidfile,'w') {|f| f << pid}
    end
    
    pid
  end
  
  def self.run_async(command,options={})
    command = "cap -v -v #{command}"
    
    t = Thread.new do
      
      out_read,out_write = IO.pipe
      err_read,err_write = IO.pipe
      in_read,in_write   = IO.pipe
    
      pid = fork do
        out_read.close
        STDOUT.reopen out_write
        out_write.close
      
        err_read.close
        STDERR.reopen err_write
        err_write.close
      
        in_write.close
        STDIN.reopen in_read
        in_read.close
        
        STDERR.sync = STDOUT.sync = true
      
        exec command
      end
    
      [out_write,err_write,in_read].each {|p| p.close}
      
      while !Process.waitpid(pid,Process::WNOHANG)
        $stdout.sync = true
        puts "waiting for input"
        
        _,read,_ = select([],[out_read,err_read],[],nil)
        read.each {|r| puts r.read; }
      end
      
      # rpid,status = Process.waitpid2(pid)
      
      puts "child #{pid} ended, eh #{$?}"
      puts "o "+out_read.read
      puts "e" +err_read.read
    end
    
    t
  end
end