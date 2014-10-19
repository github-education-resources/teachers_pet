require 'spec_helper'

describe 'clone_repos' do
  include CommandHelpers

  it "runs" do
    request_stubs = []

    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg',
      login: 'testorg',
      url: 'https://api.github.com/orgs/testorg'
    )
    student_usernames.each do |username|
      request_stubs << stub_get_json("https://testteacher:abc123@api.github.com/repos/testorg/#{username}-testrepo", {})
      expect_any_instance_of(TeachersPet::Actions::CloneRepos).to receive(:execute).with("git clone https://github.com/testorg/#{username}-testrepo.git").once
    end

    teachers_pet(:clone_repos,
      repository: 'testrepo',
      organization: 'testorg',

      students: students_list_fixture_path,

      username: 'testteacher',
      password: 'abc123'
    )

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end
end
