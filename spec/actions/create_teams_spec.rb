require 'spec_helper'

describe TeachersPet::Actions::CreateTeams do
  let(:action) { TeachersPet::Actions::CreateTeams.new }

  before do
    # fallback
    action.stub(:ask){|question| raise("can't ask \"#{question}\"") }
    action.stub(:choose){ raise("can't choose()") }

    action.stub(:confirm)
  end

  it "creates teams if none exist" do
    respond("What is the organization name?", 'testorg')
    respond("What is the name of the list of student IDs", students_list_fixture_path)
    respond("What is the name of the list of instructor IDs", instructors_list_fixture_path)
    stub_github_config

    teams_stub = stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', [])

    request_stubs = []
    student_usernames.each do |student|
      request_stubs << stub_request(:post, 'https://testteacher:abc123@api.github.com/orgs/testorg/teams').
         with(body: {
           name: student,
           permission: 'push'
         }.to_json)
    end

    action.run

    expect(teams_stub).to have_been_requested.twice
    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end

  it "handles existing teams"
end
