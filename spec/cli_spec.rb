require 'spec_helper'

describe TeachersPet::Cli do
  include CommandHelpers

  # the command in each of these tests is arbitrary

  it "throws an error for unsupported options" do
    # Make sure it short-circuits
    expect(TeachersPet::Actions::CreateStudentTeams).to_not receive(:new)

    output = capture(:stderr) {
      TeachersPet::Cli.start(%w(create_student_teams --organization testorg --unsupported-option))
    }
    expect(output).to include('--unsupported-option')
  end

  it "shows the help output" do
    stderr = nil
    stdout = capture(:stdout) {
      stderr = capture(:stderr) {
        TeachersPet::Cli.start(%w(help))
      }
    }
    expect(stderr).to eq('')
    expect(stdout).to include('create_student_teams')
  end
end
