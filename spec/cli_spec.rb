require 'spec_helper'

describe TeachersPet::Cli do
  include CommandHelpers

  it "throws an error for unsupported options" do
    # ...using an arbirtrary command

    # Make sure it short-circuits
    expect(TeachersPet::Actions::CreateTeams).to_not receive(:new)

    output = capture(:stderr) {
      TeachersPet::Cli.start(%w(create_teams --organization testorg --unsupported-option))
    }
    expect(output).to include('--unsupported-option')
  end
end
