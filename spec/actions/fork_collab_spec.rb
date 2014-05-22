require 'spec_helper'

describe TeachersPet::Actions::ForkCollab do
  let(:action) { TeachersPet::Actions::ForkCollab.new }

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
    respond("Which repository? (owner/repo)", 'testorg/testrepo')
    stub_github_config

    request_stubs = []
    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/repos/testorg/testrepo/forks?per_page=100', [
      {
        owner: {
          login: 'teststudent',
          type: 'User'
        }
      }
    ])
    request_stubs << stub_request(:put, 'https://testteacher:abc123@api.github.com/repos/testorg/testrepo/collaborators/teststudent')

    action.run

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end
end
