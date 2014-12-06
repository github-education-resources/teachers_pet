require 'spec_helper'

describe 'add_to_team' do
  include CommandHelpers

  it "adds users to the team matching the filename" do
    request_stubs = []

    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', [
      {
        id: 101,
        name: 'instructors'
      }
    ])

    users = instructor_usernames
    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/teams/101/members?per_page=100', [
      {
        login: users.first
      }
    ])

    users[1..-1].each do |instructor|
      request_stubs << stub_request(:put, "https://testteacher:abc123@api.github.com/teams/101/memberships/#{instructor}")
    end

    teachers_pet(:add_to_team,
      organization: 'testorg',
      members: instructors_list_fixture_path,

      username: 'testteacher',
      password: 'abc123'
    )

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end

  it "creates the team if it doesn't exist" do
    request_stubs = []

    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', [
      {}
    ])

    request_stubs << stub_request(:post, "https://testteacher:abc123@api.github.com/orgs/testorg/teams").
      with(body: {
        name: "instructors",
        permission: "push"
      }.to_json)

    teachers_pet(:add_to_team,
      organization: 'testorg',
      members: instructors_list_fixture_path,

      username: 'testteacher',
      password: 'abc123'
    )

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end

  it "treats the team names case-insensitively"
end
