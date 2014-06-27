require 'spec_helper'

describe 'forks' do
  include CommandHelpers

  let(:members_file){ 'students.csv' }

  after do
    FileUtils.rm_f(members_file)
  end

  context 'through CLI' do
    it "requires the repository be specified" do
      expect {
        teachers_pet(:forks)
      }.to raise_error(Thor::RequiredArgumentMissingError, /--repository/)
    end

    it "passes the options to the action" do
      expect_to_be_run_with(TeachersPet::Actions::Forks,
        'api' => 'https://api.github.com/',
        'output' => members_file,
        'password' => 'abc123',
        'repository' => 'testorg/testrepo',
        'username' => ENV['USER'],
        'web' => 'https://www.github.com/'
      )
      teachers_pet(:forks, repository: 'testorg/testrepo', password: 'abc123')
    end

    context "with a different filename" do
      let(:members_file){ './users.txt' }

      it "writes to that file" do
        request_stub = stub_get_json('https://testteacher:abc123@api.github.com/repos/testorg/testrepo/forks?per_page=100', [
          {
            owner: {
              login: 'teststudent',
              type: 'User'
            }
          }
        ])

        teachers_pet(:forks,
          repository: 'testorg/testrepo',
          output: members_file,
          username: 'testteacher',
          password: 'abc123'
        )

        expect(File.read(members_file)).to eq("teststudent\n")
        expect(request_stub).to have_been_requested.once
      end
    end

    it "succeeds for basic auth" do
      request_stub = stub_get_json('https://testteacher:abc123@api.github.com/repos/testorg/testrepo/forks?per_page=100', [
        {
          owner: {
            login: 'teststudent',
            type: 'User'
          }
        }
      ])

      teachers_pet(:forks,
        repository: 'testorg/testrepo',
        username: 'testteacher',
        password: 'abc123'
      )

      expect(File.read(members_file)).to eq("teststudent\n")
      expect(request_stub).to have_been_requested.once
    end

    it "succeeds for OAuth" do
      request_stub = stub_get_json('https://api.github.com/repos/testorg/testrepo/forks?per_page=100', [
        {
          owner: {
            login: 'teststudent',
            type: 'User'
          }
        }
      ]).with(headers: {'Authorization' => 'token tokentokentoken'})

      teachers_pet(:forks,
        repository: 'testorg/testrepo',
        token: 'tokentokentoken'
      )

      expect(File.read(members_file)).to eq("teststudent\n")
      expect(request_stub).to have_been_requested.once
    end
  end
end
