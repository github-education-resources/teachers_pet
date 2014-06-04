require 'spec_helper'

describe TeachersPet::Cli do
  let(:script) { TeachersPet::Cli.new }

  describe '#fork_collab' do
    it "requires the repository be specified" do
      expect {
        script.invoke(:fork_collab)
      }.to raise_error(Thor::RequiredArgumentMissingError, /--repository/)
    end

    it "passes the options to the action" do
      expect(TeachersPet::Actions::ForkCollab).to receive(:new).with(
        'api' => 'https://api.github.com/',
        'repository' => 'testorg/testrepo',
        'username' => 'afeld',
        'web' => 'https://www.github.com/'
      ).once.and_call_original
      expect_any_instance_of(TeachersPet::Actions::ForkCollab).to receive(:run).once

      script.invoke(:fork_collab, [], repository: 'testorg/testrepo')
    end
  end
end
