require 'spec_helper'

describe TeachersPet::Actions::CloneRepos do
  let(:cloner) { TeachersPet::Actions::CloneRepos.new }

  def respond(question, response)
    cloner.stub(:ask).with(question).and_return(response)
  end

  before do
    # fallback
    cloner.stub(:ask){|question| raise("can't ask \"#{question}\"") }
    cloner.stub(:choose){ raise("can't choose()") }

    cloner.stub(:confirm)
  end

  describe '#run' do
    it "prompts for the repository" do
      respond("What repository name should be cloned for each student?", 'testrepo')
      respond("What is the organization name?", 'testorg')
      respond("What is the name of the list of student IDs", students_list_fixture_path)
      cloner.stub(get_clone_method: 'https')
      respond("What is the organization name?", "testorg")
      respond("What is the API endpoint?", TeachersPet::Configuration.apiEndpoint)
      respond("What is the Web endpoint?", TeachersPet::Configuration.webEndpoint)
      respond("What is your username? (You must be an owner for the organization)?", 'testteacher')
      cloner.stub(get_auth_method: 'password')
      respond("What is your password?", 'abc123')

      request_stubs = []

      request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg',
        login: 'testorg',
        url: 'https://api.github.com/orgs/testorg'
      )
      request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', student_teams)
      student_usernames.each do |username|
        request_stubs << stub_get_json("https://testteacher:abc123@api.github.com/repos/testorg/#{username}-testrepo", {})
        cloner.should_receive(:execute).with("git clone https://www.github.com/testorg/#{username}-testrepo.git").once
      end

      cloner.run

      request_stubs.each do |request_stub|
        expect(request_stub).to have_been_requested.once
      end
    end
  end
end
