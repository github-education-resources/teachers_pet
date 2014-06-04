require 'spec_helper'

describe TeachersPet::Actions::ForkCollab do
  let(:cls) { TeachersPet::Actions::ForkCollab }

  def expect_to_be_run_with(opts)
    expect(cls).to receive(:new).with(opts).once.and_call_original
    expect_any_instance_of(cls).to receive(:run).once
  end

  context 'through CLI' do
    it "requires the repository be specified" do
      expect {
        teachers_pet(:fork_collab)
      }.to raise_error(Thor::RequiredArgumentMissingError, /--repository/)
    end

    it "passes the options to the action" do
      expect_to_be_run_with(
        'api' => 'https://api.github.com/',
        'repository' => 'testorg/testrepo',
        'username' => ENV['USER'],
        'web' => 'https://www.github.com/'
      )
      teachers_pet(:fork_collab, repository: 'testorg/testrepo')
    end

    it "succeeds with all required arguments" do
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
