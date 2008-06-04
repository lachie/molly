# encapsulates the residue of a run of a task

class Log
  attr_reader :key,:task,:date,:status
  
  def initialize(file,app)
    @file,@app = file,app
    
    _,@key,@task = *@file.match(/(\d+)_([\w:]+)\.log/)
    @date = DateTime.strptime(@key,"%Y%m%d%H%M%S")
    
    begin
      @status = File.read(@app.status_path(@key))
    rescue Errno::ENOENT
      @status = 'unknown'
    end
  end
  
  def each_line(&block)
    IO.foreach(@file) do |line|
      line.chomp!
      
      stream = line[0] == ?O ? 'out' : 'err'
      
      line[0,2] = ''
      yield(line,stream)
    end
  end
  
  def success?
    @status == 'success'
  end
  
  def running?
    @status == 'running'
  end
  
  def failure?
    @status == 'failure'
  end
end