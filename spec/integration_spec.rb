require 'spec_helper'
require 'open3'

describe 'integration' do
  describe 'help' do
    it "shows the help output" do
      stdout_str, stderr_str, status = Open3.capture3('bin/teachers_pet help')
      expect(stderr_str).to eq('')
      expect(status).to be_success
    end
  end
end
