require 'spec_helper'

describe TeachersPet::Actions::ForkCollab do
  context 'through CLI' do
    it "requires the repository be specified" do
      expect {
        teachers_pet(:fork_collab)
      }.to raise_error(Thor::RequiredArgumentMissingError, /--repository/)
    end

    it "passes the options to the action" do
      expect(TeachersPet::Actions::ForkCollab).to receive(:new).with(
        'api' => 'https://api.github.com/',
        'repository' => 'testorg/testrepo',
        'username' => 'afeld',
        'web' => 'https://www.github.com/'
      ).once.and_call_original
      expect_any_instance_of(TeachersPet::Actions::ForkCollab).to receive(:run).once

      teachers_pet(:fork_collab, repository: 'testorg/testrepo')
    end

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

      teachers_pet(:fork_collab,
        repository: 'testorg/testrepo',
        username: 'testteacher',
        password: 'abc123'
      )

      request_stubs.each do |request_stub|
        expect(request_stub).to have_been_requested.once
      end
    end
  end
end
