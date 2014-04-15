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
      students_file_path = File.join(File.dirname(__FILE__), '..', 'fixtures', 'students.csv')

      respond("What repository name should be cloned for each student?", 'testrepo')
      respond("What is the organization name?", 'testorg')
      respond("What is the name of the list of student IDs", students_file_path)
      cloner.stub(get_clone_method: 'https')
      respond("What is the organization name?", "testorg")
      respond("What is the API endpoint?", TeachersPet::Configuration.apiEndpoint)
      respond("What is the Web endpoint?", TeachersPet::Configuration.webEndpoint)
      respond("What is your username? (You must be an owner for the organization)?", 'testteacher')
      cloner.stub(get_auth_method: 'password')
      respond("What is your password?", 'abc123')

      stub_request(:get, 'https://testteacher:abc123@api.github.com/orgs/testorg').to_return(
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          login: 'testorg',
          url: 'https://api.github.com/orgs/testorg'
        }.to_json
      )

      stub_request(:get, 'https://testteacher:abc123@api.github.com/orgs/testorg/teams').to_return(
        headers: {
          'Content-Type' => 'application/json'
        },
        body: [
          {
            url: 'https://api.github.com/teams/1',
            name: 'Owners',
            id: 1
          }
        ].to_json
      )

      cloner.run
    end
  end
end
