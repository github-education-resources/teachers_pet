require 'spec_helper'

describe 'create_teams' do
  include CommandHelpers

  def stub_owners_only
    stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', [
      {
        id: 101,
        name: 'Owners'
      }
    ])
  end

  it "creates one team per student" do
    request_stubs = []
    request_stubs << stub_owners_only

    student_usernames.each_with_index do |student, i|
      # Creates team
      request_stubs << stub_request(:post, 'https://testteacher:abc123@api.github.com/orgs/testorg/teams').
         with(body: {
           name: student,
           permission: 'push'
         }.to_json).to_return(body: {
            id: i,
            name: student
         })

      # Checks for existing team members
      # TODO No need to retrieve members for a new team
      request_stubs << stub_get_json("https://testteacher:abc123@api.github.com/teams/#{i}/members?per_page=100", [])

      # Add student to their team
      request_stubs << stub_request(:put, "https://testteacher:abc123@api.github.com/teams/#{i}/members/#{student}")
    end

    teachers_pet(:create_teams,
      organization: 'testorg',

      students: students_list_fixture_path,
      instructors: empty_list_fixture_path,

      username: 'testteacher',
      password: 'abc123'
    )

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end

  it "creates teams for groups of students" do
    request_stubs = []
    stub_owners_only

    # Creates team
    request_stubs << stub_request(:post, 'https://testteacher:abc123@api.github.com/orgs/testorg/teams').
       with(body: {
         name: 'studentteam1',
         permission: 'push'
       }.to_json).to_return(body: {
          id: 1,
          name: 'studentteam1'
       })

    # Checks for existing team members
    # TODO No need to retrieve members for a new team
    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/teams/1/members?per_page=100', [])

    %w(teststudent1 teststudent2).each do |student|
      # Add student to their team
      request_stubs << stub_request(:put, "https://testteacher:abc123@api.github.com/teams/1/members/#{student}")
    end

    teachers_pet(:create_teams,
      organization: 'testorg',

      students: fixture_path('teams'),
      instructors: empty_list_fixture_path,

      username: 'testteacher',
      password: 'abc123'
    )

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end

  it "adds instructors to owners team" do
    request_stubs = []

    request_stubs << stub_owners_only
    instructors = instructor_usernames
    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/teams/101/members?per_page=100', [
      {
        login: instructors.first
      }
    ])

    instructors[1..-1].each do |instructor|
      request_stubs << stub_request(:put, "https://testteacher:abc123@api.github.com/teams/101/members/#{instructor}")
    end

    teachers_pet(:create_teams,
      organization: 'testorg',

      students: empty_list_fixture_path,
      instructors: instructors_list_fixture_path,

      username: 'testteacher',
      password: 'abc123'
    )

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end
end
