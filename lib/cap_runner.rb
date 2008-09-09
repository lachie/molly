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
    return unless file
    
    FileUtils::rm("#{file}.*")
    FileUtils::touch("#{file}.#{status}")
  end
  
  # TODO, split this up
  def self.run_async(command,options={})
    command = "cap #{command}"
    
    t = Thread.new do
      begin
      
        # open some bidirectional pipes
        out_read,out_write = IO.pipe
        err_read,err_write = IO.pipe
        in_read,in_write   = IO.pipe
    
        pid = fork do
        
          # redirect out and err by reopening and closing the pipes appropriately
          out_read.close
          STDOUT.reopen out_write
          out_write.close
      
          err_read.close
          STDERR.reopen err_write
          err_write.close
      
          in_write.close
          STDIN.reopen in_read
          in_read.close
        
          # turn off the buffers
          STDERR.sync = STDOUT.sync = true
        
          # drop into the command
          exec command
        end
      
        # write the pid file
        set_status(options[:pid]   ,pid) if pid
        set_status(options[:status],"running")
    
        # in parent, close un-needed ends of the pipes
        [out_write,err_write,in_read].each {|p| p.close}
      
        # start a log
        log = open(options[:log],'a') if options[:log]

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
          
            log.puts "#{marker} #{r.readpartial(4096).chomp.gsub(/\n/,"\n#{marker} ")}" if log
          end
        end

        # wait for the process to end
        rpid,status = Process.waitpid2(pid)
      
        set_status(options[:status], status.success? ? "success" : "failure")
      
        log.puts "O #{pid} ended with [#{status.exitstatus}]" if log
      
      rescue
        set_status(options[:status], "failure")
        log.puts "O running #{pid} failed [#{$!}]" if log
      ensure
        log.close if log
      end
    end
    
    t
  end
end