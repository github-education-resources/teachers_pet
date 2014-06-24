require 'spec_helper'

describe 'forks' do
  include CommandHelpers

  after do
    FileUtils.rm_f('./students.csv')
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
        'password' => 'abc123',
        'repository' => 'testorg/testrepo',
        'username' => ENV['USER'],
        'web' => 'https://www.github.com/'
      )
      teachers_pet(:forks, repository: 'testorg/testrepo', password: 'abc123')
    end

    it "succeeds for basic auth" do
      request_stubs = []
      request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/repos/testorg/testrepo/forks?per_page=100', [
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

      expect(File.read('./students.csv')).to eq("teststudent\n")

      request_stubs.each do |request_stub|
        expect(request_stub).to have_been_requested.once
      end
    end

    it "succeeds for OAuth" do
      request_stubs = []
      request_stubs << stub_get_json('https://api.github.com/repos/testorg/testrepo/forks?per_page=100', [
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

      expect(File.read('./students.csv')).to eq("teststudent\n")

      request_stubs.each do |request_stub|
        expect(request_stub).to have_been_requested.once
      end
    end
  end
end
