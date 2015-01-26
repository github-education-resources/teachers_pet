require 'spec_helper'

describe TeachersPet::Cli do
  include CommandHelpers

  # the command in each of these tests is arbitrary

  it "throws an error for unsupported options" do
    # Make sure it short-circuits
    expect(TeachersPet::Actions::CreateStudentTeams).to_not receive(:new)

    expect {
      TeachersPet::Cli.start(%w(create_student_teams --organization testorg --unsupported-option))
    }.to output(/--unsupported-option/).to_stderr

  end

  it "shows the help output" do
    expect {
      TeachersPet::Cli.start(%w(help))
    }.to output(/create_student_teams/).to_stdout
  end
end
