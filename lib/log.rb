# encapsulates the residue of a run of a task

class Log
  attr_reader :key,:task,:date
  
  def initialize(file,app)
    @file,@app = file,app
    
    _,@key,@task = *@file.match(/(\d+)_([\w:,]+)\.log/)
    @date = DateTime.strptime(@key,"%Y%m%d%H%M%S")
    

  end
  
  def status
    unless @status
      begin
        status = Dir["#{@app.status_path(@key)}.*"].first || '.unknown'
        @status = status[/\.([^\.]*)$/,1]
      rescue Errno::ENOENT
        @status = 'unknown'
      end
    end

    @status
  end
  
  def each_line(&block)
    IO.foreach(@file) do |line|
      line.chomp!
      
      stream = case line[0]
                when ?O
                  'out'
                when ?E
                  'err'
                when ?R
                  'reason'
                end
      
      line[0,2] = ''
      yield(line,stream)
    end
  end
  
  def success?
    status == 'success'
  end
  
  def running?
    status == 'running'
  end
  
  def failure?
    status == 'failure'
  end
end