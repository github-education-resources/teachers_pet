require 'spec_helper'

describe 'delete_repos' do
  include CommandHelpers
  include_context "with expected requests"

  def stub_student_create_repo_requests(create_as_public)
    student_usernames.each do |username|
      # Check for the repos existing already
      stub_request(:get, "https://testteacher:abc123@api.github.com/repos/testorg/#{username}-testrepo").
        to_return(status: 404)
    end
    student_usernames.each do |username|
      # create the repo for test
      team_id = 0
      student_teams.each do |st|
        if st[:name].eql?(username)
          team_id = st[:id]
        end
      end
      stub_request(:post, "https://testteacher:abc123@api.github.com/orgs/testorg/repos").
        with(body: {
          description: "testrepo created for #{username}",
          private: !create_as_public,
          has_issues: true,
          has_wiki: false,
          has_downloads: false,
          team_id: team_id,
          name: "#{username}-testrepo"
        }.to_json)
    end
  end

  def teachers_pet_create_repos!(create_as_public)
    teachers_pet(:create_repos,
      repository: 'testrepo',
      organization: 'testorg',
      public: create_as_public,
      students: students_list_fixture_path,
      username: 'testteacher',
      password: 'abc123'
    )
  end

  def stub_get_org_request
    stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg',
      login: 'testorg',
      url: 'https://api.github.com/orgs/testorg'
    )
  end

  def stub_get_org_teams_request
    stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', student_teams)
  end

  before(:each) do
    @expected_requests << stub_get_org_request
    @expected_requests << stub_get_org_teams_request
  end

  it "deletes public repos" do
    stub_student_create_repo_requests(true)
    teachers_pet_create_repos!(true)
    teachers_pet(:delete_repos,
      repository: 'testrepo',
      organization: 'testorg',
      students: students_list_fixture_path,
      username: 'testteacher',
      password: 'abc123'
    )
  end

  it "deletes private repos" do
    stub_student_create_repo_requests(false)
    teachers_pet_create_repos!(false)
    teachers_pet(:delete_repos,
      repository: 'testrepo',
      organization: 'testorg',
      students: students_list_fixture_path,
      username: 'testteacher',
      password: 'abc123'
    )
  end
end
