require 'spec_helper'

describe 'add_collaborators' do
  include CommandHelpers

  def stub_add_students
    student_usernames.map do |username|
      stub_request(:put, "https://testteacher:abc123@api.github.com/repos/testorg/testrepo/collaborators/#{username}")
    end
  end

  context 'through CLI' do
    it "requires the repository be specified" do
      expect {
        teachers_pet(:add_collaborators)
      }.to raise_error(Thor::RequiredArgumentMissingError, /--repository/)
    end

    it "passes the options to the action" do
      expect_to_be_run_with(TeachersPet::Actions::AddCollaborators,
        'api' => 'https://api.github.com/',
        'dry_run' => false,
        'members' => students_list_fixture_path,
        'password' => 'abc123',
        'repository' => 'testorg/testrepo',
        'username' => ENV['USER'],
        'web' => 'https://github.com/'
      )

      teachers_pet(:add_collaborators,
        repository: 'testorg/testrepo',
        members: students_list_fixture_path,
        password: 'abc123'
      )
    end

    it "succeeds for basic auth" do
      request_stubs = student_usernames.map do |username|
        stub_request(:put, "https://testteacher:abc123@api.github.com/repos/testorg/testrepo/collaborators/#{username}")
      end

      teachers_pet(:add_collaborators,
        repository: 'testorg/testrepo',
        members: students_list_fixture_path,
        username: 'testteacher',
        password: 'abc123'
      )

      request_stubs.each do |request_stub|
        expect(request_stub).to have_been_requested.once
      end
    end

    it "succeeds for OAuth" do
      request_stubs = student_usernames.map do |username|
        stub_request(:put, "https://api.github.com/repos/testorg/testrepo/collaborators/#{username}").with(headers: {'Authorization'=>'token tokentokentoken'})
      end

      teachers_pet(:add_collaborators,
        repository: 'testorg/testrepo',
        members: students_list_fixture_path,
        token: 'tokentokentoken'
      )

      request_stubs.each do |request_stub|
        expect(request_stub).to have_been_requested.once
      end
    end

    it "prints the users on a dry run" do
      output = capture(:stdout) do
        teachers_pet(:add_collaborators,
          repository: 'testorg/testrepo',
          members: students_list_fixture_path,
          username: 'testteacher',
          password: 'abc123',
          dry_run: true
        )
      end

      expect(output).to include('teststudent1')
    end
  end
end
