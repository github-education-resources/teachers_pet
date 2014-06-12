require 'spec_helper'

describe TeachersPet::Actions::CreateRepos do
  include CliHelpers

  def common_test(create_as_public)
    request_stubs = []

    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg',
      login: 'testorg',
      url: 'https://api.github.com/orgs/testorg'
    )
    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', student_teams)
    student_usernames.each do |username|
      # Check for the repos existing already
      stub_request(:get, "https://testteacher:abc123@api.github.com/repos/testorg/#{username}-testrepo").
        to_return(status: 404)
    end

    student_usernames.each do |username|
      # actually create the repo
      team_id = 0
      student_teams.each do |st|
        if st[:name].eql?(username)
          team_id = st[:id]
        end
      end
      stub_request(:post, "https://testteacher:abc123@api.github.com/orgs/testorg/repos").
        with(body: "{\"description\":\"testrepo created for #{username}\",\"private\":#{!create_as_public},\"has_issues\":true,\"has_wiki\":false,\"has_downloads\":false,\"team_id\":#{team_id},\"name\":\"#{username}-testrepo\"}")
    end

    teachers_pet(:create_repos,
      repository: 'testrepo',
      organization: 'testorg',
      public: create_as_public,

      students: students_list_fixture_path,

      username: 'testteacher',
      password: 'abc123'
    )

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end

  it "create repos public" do
    common_test(true)
  end

  it "create repos private" do
    common_test(false)
  end
end
