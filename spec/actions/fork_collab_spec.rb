require 'spec_helper'

describe TeachersPet::Actions::ForkCollab do
  it "runs" do
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

    action = TeachersPet::Actions::ForkCollab.new(
      'repository' => 'testorg/testrepo'
    )
    action.run

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end
end
