require 'spec_helper'

describe TeachersPet::Actions::PushFiles do
  include CliHelpers

  it "runs" do
    request_stubs = []
    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg',
      login: 'testorg',
      name: 'Test Org',
      url: 'http://test.org'
    )
    request_stubs << stub_get_json('https://testteacher:abc123@api.github.com/orgs/testorg/teams?per_page=100', [
      {
        name: 'teststudent'
      }
    ])

    teachers_pet(:push_files,
      repository: 'assignment',
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
