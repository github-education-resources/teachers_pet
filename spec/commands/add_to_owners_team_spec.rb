require 'spec_helper'

describe 'add_to_owners_team' do
  include CommandHelpers

  def stub_owners_only
    stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', [
      {
        id: 101,
        name: 'Owners'
      }
    ])
  end

  it "adds users to owners team" do
    request_stubs = []

    request_stubs << stub_owners_only
    users = instructor_usernames
    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/teams/101/members?per_page=100', [
      {
        login: users.first
      }
    ])

    users[1..-1].each do |instructor|
      request_stubs << stub_request(:put, "https://testteacher:abc123@api.github.com/teams/101/members/#{instructor}")
    end

    teachers_pet(:add_to_owners_team,
      organization: 'testorg',
      members: instructors_list_fixture_path,

      username: 'testteacher',
      password: 'abc123'
    )

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end
end
