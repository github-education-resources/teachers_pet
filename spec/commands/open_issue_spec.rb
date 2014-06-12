require 'spec_helper'

describe 'open_issue' do
  include CommandHelpers

  context 'through CLI' do
    def common_test(labels='')
      issue_title = "Issue Test"
      request_stubs = []

      request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg',
        login: 'testorg',
        url: 'https://api.github.com/orgs/testorg'
      )
      request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', student_teams)
      student_usernames.each do |username|
        # Action checks that repos exist already
        request_stubs << stub_request(:get, "https://testteacher:abc123@api.github.com/repos/testorg/#{username}-testrepo")
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
        request_stubs << stub_request(:post, "https://testteacher:abc123@api.github.com/repos/testorg/#{username}-testrepo/issues").
          with(body: "{\"labels\":#{labels_list},\"title\":\"#{issue_title}\",\"body\":\"#{issue_body}\"}").
          to_return(status: 201)
      end

      teachers_pet(:open_issue,
        repository: 'testrepo',
        organization: 'testorg',

        title: issue_title,
        body: issue_fixture_path,
        labels: labels,

        students: students_list_fixture_path,

        username: 'testteacher',
        password: 'abc123'
      )

      request_stubs.each do |request_stub|
        expect(request_stub).to have_been_requested.once
      end
    end

    it "open issue no labels" do
      common_test
    end

    it "open issue with labels" do
      common_test('bug, feature')
    end
  end
end
