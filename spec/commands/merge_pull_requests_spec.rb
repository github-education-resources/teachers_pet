require 'spec_helper'

describe 'merge_pull_requests' do
  include CommandHelpers

  it "merges all open pull requests in a particular repository" do
    request_stubs = []
    request_stubs << stub_get_json("https://testteacher:abc123@api.github.com/repos/testorg/testrepo/pulls?per_page=100&state=open", [
      { id: 1, html_url: "https://github.com/testorg/testrepo/pull/1", number: 1 },
      { id: 2, html_url: "https://github.com/testorg/testrepo/pull/2", number: 2 },
      { id: 3, html_url: "https://github.com/testorg/testrepo/pull/3", number: 3 }
    ])

    (1..3).to_a.each do |i|
      request_stubs << stub_request(:put, "https://testteacher:abc123@api.github.com/repos/testorg/testrepo/pulls/#{i}/merge")
    end

    teachers_pet(:merge_pull_requests,
      repository: 'testorg/testrepo',

      username: 'testteacher',
      password: 'abc123'
    )

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end
end
