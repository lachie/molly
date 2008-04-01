class CapRunner
   
  def self.run(command)
    output = %x{cap #{command}}
    
     $?.success? ? output : nil
  end
  
  def self.run_async(command,options={})
    command = "cap #{command}"
    
    t = Thread.new do
      
      out_read,out_write = IO.pipe
      err_read,err_write = IO.pipe
      in_read,in_write   = IO.pipe
    
      pid = fork do
        # redirect out and err
        
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
      
      if pid and pidfile = options[:pid]
        File.open(pidfile,'w') {|f| f << pid}
      end
    
      # in parent
      [out_write,err_write,in_read].each {|p| p.close}
      
      log = open(options[:log],'w') if options[:log]

      $stdout.sync = true
      while ready = select([out_read,err_read])
        next if ready.empty?
        
        read = ready.first

        break if read.all? {|r| r.eof?}
        read.each do |r|
          next if r.eof?
          
          marker = r == out_read ? 'O' : 'E'
          
          log.puts "#{marker} #{r.readpartial(4096).chomp.gsub(/\n/,"\n#{marker} ")}" if log
        end
      end
      

      
      rpid,status = Process.waitpid2(pid)
      
      log.puts "O #{pid} ended with [#{status}]" if log

      log.close if log
    end
    
    
    t
  end
end