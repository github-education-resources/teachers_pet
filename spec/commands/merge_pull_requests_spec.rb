require 'spec_helper'
require 'pry'

describe 'merge_pull_requests' do
  include CommandHelpers

  it "merges all open pull requests in a particular repository" do
    request_stubs = []
    request_stubs << stub_request(:get, "https://testteacher:abc123@api.github.com/repos/testorg/testrepo/pulls")

    pull_requests.each_with_index do |pr, i|
      request_stubs << stub_request(:put, "https://testteacher:abc123@api.github.com/repos/testorg/testrepo/pulls/#{i}/merge")
    end

    teachers_pet(:merge_pull_requests,
      repository: 'testrepo',

      username: 'testteacher',
      password: 'abc123'
    )

    request_stubs.each do |request_stub|
      expect(request_stub).to have_been_requested.once
    end
  end
end
