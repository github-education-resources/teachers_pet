require 'spec_helper'

describe 'version' do
  include CommandHelpers

  it "prints the version number" do
    expect {
      teachers_pet(:version)
    }.to output("#{TeachersPet::VERSION}\n").to_stdout
  end
end
