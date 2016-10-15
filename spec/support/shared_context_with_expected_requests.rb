shared_context "with expected requests" do
  before(:each) do
    @expected_requests = []
  end

  after(:each) do
    @expected_requests.each do |request_stub|
      expect(request_stub).to have_been_requested.at_least_once
    end
  end
end
