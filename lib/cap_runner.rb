require 'fileutils'

class CapRunner
  
  
  def self.run(command)
    puts "running #{Merb::Config[:cap]} #{command}"
    output = %x{#{Merb::Config[:cap] || cap} #{command}}
    
    $?.success? ? output : nil
  rescue
    output
  end
  
  def self.set_status(file,status)
    return unless file && status
    
    begin
      ::Merb.logger.debug "removing #{file}.* -> #{file}.#{status}"
      FileUtils::rm("#{file}.*")
    rescue Errno::ENOENT
      ::Merb.logger.error "unable to remove #{file}.* (not found)"
    end
    
    FileUtils::touch("#{file}.#{status}")
  end
  
  def self.set_pid(file,pid)
    return unless file && pid
    
    open(file,"w") {|f| f << pid}
  end
  
  def self.reopen(target,to_reopen,to_close)
    to_close.close
    
    target.reopen to_reopen
    to_reopen.close
  end
  
  # TODO, split this up
  def self.run_async(command,options={})
    command = "cap #{command}"
    
    raise ArgumentError, "no log supplied" unless options[:log]
    
    t = Thread.new do
      begin
      
        log = open(options[:log],'a')
        
        # open some bidirectional pipes
        out_read,out_write = IO.pipe
        err_read,err_write = IO.pipe
        in_read,in_write   = IO.pipe
    
        pid = fork do
        
          # redirect out and err by reopening and closing the pipes appropriately
          reopen(STDOUT, out_write, out_read)
          reopen(STDERR, err_write, err_read)
          reopen(STDIN , in_read  , in_write)
        
          # turn off the buffers
          STDERR.sync = STDOUT.sync = true
        
          # drop into the command
          exec command
        end
      
        # write the pid file
        set_pid(options[:pid]   , pid)
        set_status(options[:status], "running")
    
        # in parent, close un-needed ends of the pipes
        [out_write,err_write,in_read].each {|p| p.close}
      
        # write to the shared log
        Merb.logger.debug( "log: #{options[:log]}")
        

        # use a select loop to wait for output
        $stdout.sync = true
        while ready = select([out_read,err_read])
          next if ready.empty?
          read = ready.first

          break if read.all? {|r| r.eof?}
          read.each do |r|
            next if r.eof?
          
            # set a marker denoting which stream we're reading from
            marker = r == out_read ? 'O' : 'E'
          
            log.puts "#{marker} #{r.readpartial(4096).chomp.gsub(/\n/,"\n#{marker} ")}"
          end
        end

        # wait for the process to end
        rpid,status = Process.waitpid2(pid)
      
        set_status(options[:status], status.success? ? "success" : "failure")
      
        log.puts "O #{pid} ended with [#{status.exitstatus}]"
      
      rescue
        set_status(options[:status], "failure")
        log.puts "O running #{pid} failed [#{$!}]"
      ensure
        log.close if log
      end
    end
    
    t
  end
end