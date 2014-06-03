require 'spec_helper'

describe TeachersPet::Actions::OpenIssue do
  let(:action) { TeachersPet::Actions::OpenIssue.new }

  before do
    # fallback
    allow(action).to receive(:ask){|question| raise("can't ask \"#{question}\"") }
    allow(action).to receive(:choose){ raise("can't choose()") }

    allow(action).to receive(:confirm)
  end

  def common_test(labels)
    
    issue_title = "Issue Test"
    
    # Respond to action prompts
    respond("What repository will the issue be raised in?", 'testrepo')
    respond("What is the organization name?", 'testorg')
    respond("What is the title of the issue?", 'Issue Test')
    respond("What is the path to the file containing the issue body?", issue_fixture_path)
    respond("Optionally add any labels, seperated by commas:", labels)
    respond("What is the filename of the list of students?", students_list_fixture_path)
    respond("What is the filename of the list of instructors?", instructors_list_fixture_path)
    respond("Create issue '#{issue_title}' in #{File.open(students_list_fixture_path).readlines.size} student repositories - 'testrepo'?", "1")
    stub_github_config

    request_stubs = []

    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg',
      login: 'testorg',
      url: 'https://api.github.com/orgs/testorg'
    )
    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', student_teams)
    student_usernames.each do |username|
      # Action checks that repos exist already
      stub_request(:get, "https://testteacher:abc123@api.github.com/repos/testorg/#{username}-testrepo").
         to_return(:status => 200, :body => "", :headers => {})
    end

    # create the issue in each repo
    student_usernames.each do |username|
      team_id = 0
      student_teams.each do |st|
        if st[:name].eql?(username)
          team_id = st[:id]
        end
      end
      issue_body = File.read(issue_fixture_path).gsub("\n", "\\n")
      labels_list = labels.split(",").map(&:strip).to_s.delete(' ')
      stub_request(:post, "https://testteacher:abc123@api.github.com/repos/testorg/#{username}-testrepo/issues").
         with(:body => "{\"labels\":#{labels_list},\"title\":\"Issue Test\",\"body\":\"#{issue_body}\"}").
         to_return(:status => 201)
    end

    action.run

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end

  it "open issue no labels" do
    common_test("")
  end

  it "open issue with labels" do
    common_test("bug, feature")
  end
end
