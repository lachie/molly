require File.dirname(__FILE__) + '/../spec_helper'

class CapRecipeFixture
  include Recipes::Capistrano
  
  def name; :fixture_app end
  def app_root; "data/fixture_app" end
  
  def pid_path(key)
    'pids' / "#{key}.pid"
  end
  
  def log_path(key)
    'logs' / "#{key}.log"
  end
end

class BadCapRecipeFixture < CapRecipeFixture
  def name; :spots end
end

describe Recipes::Capistrano do
  before do
    @app = CapRecipeFixture.new
    @bad_app = BadCapRecipeFixture.new
  end
  
  
  it "finds the Capfile for the application" do
    @app.capfile_path.should == 'data/fixture_app/Capfile'
  end

  
  describe '#recipe_tasks' do
    before do
      mock( CapRunner ).run("-Tv -f data/fixture_app/Capfile") {
        %{cap deploy             # deploy the widget
cap deploy:clandestine # 
cap deploy:refine      # refine the widgets
cap invoke             # Invoke a single command on the remote servers.
cap shell              # Begin an interactive Capistrano session.

Extended help may be available for these tasks.
Type `cap -e taskname' to view it.}            
      }
      
    end

    
    it "parses the Capfile" do
      @app.should have(3).recipe_tasks
    end
    
    it "parses the Capfile, returning tasks" do
      @app.recipe_tasks.should == [
        ['deploy'             ,'deploy the widget' ],
        ['deploy:clandestine' ,''                  ],
        ['deploy:refine'      ,'refine the widgets']
      ]
    end
  end
  
  describe '#setup_recipe with non-existent Capfile' do
    before do                                                                 
      mock( CapRunner ).run("-Tv -f data/spots/Capfile") { nil }
    end
   
    it "raises" do
      lambda { @bad_app.recipe_tasks }.should raise_error
    end
  end  

  describe '#run_task' do
    before do
      mock( CapRunner ).run_async("-f data/fixture_app/Capfile deploy",
        :pid => %r{pids/\d{14}.pid},
        :log => %r{logs/\d{14}.log}
      ) { "Deploying the widget ..." }
    end                           
    it "runs the task deploy" do
      @app.run_task("deploy").should match(/^\d{14}$/)
    end
  end
  
end