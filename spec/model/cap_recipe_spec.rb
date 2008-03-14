require File.dirname(__FILE__) + '/../spec_helper'

class CapRecipeFixture
  include Recipes::Capistrano
  
  def name; :fixture_app end
  def data_root; "data" end
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
    @app.capfile.should == 'fixture_app/Capfile'
  end
   
  describe '#recipe_tasks' do
    before do
      mock( $? ).success? { true }
      
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
      mock( CapRunner ).run("-Tv -f data/spots/Capfile") { "Bad bad capistrano" }
      mock( $? ).success? { false }
    end    
   
    it "raises" do
      lambda { @bad_app.recipe_tasks }.should raise_error
    end
  end  
  
  describe '#recipe_run_task' do
    before do
      mock( CapRunner ).run("-f data/fixture_app/Capfile deploy") { "Deploying the widget ..." }
      mock( $? ).success? { true }
    end                           
    it "runs the task deploy" do
      @app.recipe_run_task("deploy").should be_true
    end
  end
  
end