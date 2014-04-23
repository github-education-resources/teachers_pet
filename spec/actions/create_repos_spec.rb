require 'spec_helper'

describe TeachersPet::Actions::CreateRepos do
  let(:action) { TeachersPet::Actions::CreateRepos.new }

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
    respond("What repository name should be created for each student?", 'testrepo')
    respond("What is the organization name?", 'testorg')
    respond("What is the filename of the list of students?", students_list_fixture_path)
    respond("What is the filename of the list of instructors?", instructors_list_fixture_path)
    action.stub(get_public_repo_setting: 'private')
    respond("Add .gitignore and README.md files? (skip this if you are pushing starter files.)", 2)
    respond("Create 3 private repositories for students and give access to instructors?", 1)
    stub_github_config

    request_stubs = []

    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg',
      login: 'testorg',
      url: 'https://api.github.com/orgs/testorg'
    )
    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', student_teams)
    student_usernames.each do |username|
      # Check for the repos existing already
      stub_request(:get, "https://testteacher:abc123@api.github.com/repos/testorg/#{username}-testrepo").
         to_return(:status => 404, :body => "", :headers => {})
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
         with(:body => "{\"description\":\"testrepo created for #{username}\",\"private\":false,\"has_issues\":true,\"has_wiki\":false,\"has_downloads\":false,\"team_id\":#{team_id},\"auto_init\":null,\"gitignore_template\":\"\",\"name\":\"#{username}-testrepo\"}").
         to_return(:status => 200)
    end

    action.run

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end
end
