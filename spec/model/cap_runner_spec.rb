require File.dirname(__FILE__) + '/../spec_helper'

describe CapRunner do
  describe ".build_async_command" do
    it "builds the plain command" do
      CapRunner.build_async_command('dothing').should == 'cap dothing'
    end
    it "builds the logged command" do
      CapRunner.build_async_command('dothing',:log => 'logfile').should == 'cap dothing > logfile 2>&1'
    end
  end
  
  describe ".run_async" do
    it "should execute the task" do
      mock(CapRunner).fork() {1234}
      mock(File).open('pidfile','w')
      
      CapRunner.run_async("dostuff", :log => 'logfile', :pid => 'pidfile').should == 1234
    end
  end
end