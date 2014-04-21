require 'spec_helper'

describe TeachersPet::Actions::CloneRepos do
  let(:action) { TeachersPet::Actions::CloneRepos.new }

  def respond(question, response)
    action.stub(:ask).with(question).and_return(response)
  end

  before do
    # fallback
    action.stub(:ask){|question| raise("can't ask \"#{question}\"") }
    action.stub(:choose){ raise("can't choose()") }

    action.stub(:confirm)
  end

  it "runs" do
    respond("What repository name should be cloned for each student?", 'testrepo')
    respond("What is the organization name?", 'testorg')
    respond("What is the filename of the list of students?", students_list_fixture_path)
    action.stub(get_clone_method: 'https')
    respond("What is the organization name?", "testorg")
    stub_github_config

    request_stubs = []

    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg',
      login: 'testorg',
      url: 'https://api.github.com/orgs/testorg'
    )
    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', student_teams)
    student_usernames.each do |username|
      request_stubs << stub_get_json("https://testteacher:abc123@api.github.com/repos/testorg/#{username}-testrepo", {})
      action.should_receive(:execute).with("git clone https://www.github.com/testorg/#{username}-testrepo.git").once
    end

    action.run

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end
end
