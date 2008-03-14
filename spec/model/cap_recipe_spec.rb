require File.dirname(__FILE__) + '/../spec_helper'

class CapRecipeFixture
  include Recipes::Capistrano
  
  def name; :fixture_app end
  def data_root; Merb.root_path('spec','fixtures','capistrano') end
end

class BadCapRecipeFixture < CapRecipeFixture
  def name; :spots end
end

describe Recipes::Capistrano do
  before do
    @app = CapRecipeFixture.new
    @bad_app = BadCapRecipeFixture.new
  end
  
  describe '#setup_recipe' do
    it "finds the Capfile for the application" do
      @app.capfile.should == 'fixture_app/Capfile'
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
    it "raises" do
      lambda { @bad_app.recipe_tasks }.should raise_error
    end
  end
end