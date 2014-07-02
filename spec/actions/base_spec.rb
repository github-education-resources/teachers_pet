require 'spec_helper'

describe TeachersPet::Actions::Base do
  describe '#octokit_config' do
    it "complains if the password and token are missing" do
      action = TeachersPet::Actions::Base.new
      expect {
        action.octokit_config
      }.to raise_error(Thor::RequiredArgumentMissingError, /--password.+--token/)
    end

    it "uses the password if provided" do
      action = TeachersPet::Actions::Base.new(password: 'abc123')
      expect(action.octokit_config[:password]).to eq('abc123')
    end

    it "uses the token if provided" do
      action = TeachersPet::Actions::Base.new(token: 'abc123')
      expect(action.octokit_config[:access_token]).to eq('abc123')
    end

    it "waits for a password if the password flag is passed without any arguments" do
      action = TeachersPet::Actions::Base.new(password: 'password')
      STDIN.stub(:gets).and_return('abc123')
      expect(action.octokit_config[:password]).to eq('abc123')
    end

    it "waits for a token if the token flag is passed without any arguments" do
      action = TeachersPet::Actions::Base.new(token: 'token')
      STDIN.stub(:gets).and_return('abc123')
      expect(action.octokit_config[:access_token]).to eq('abc123')
    end
  end

  describe '#read_file' do
    it "returns a hash of usernames by team name" do
      action = TeachersPet::Actions::Base.new
      result = action.read_file(fixture_path('teams'))
      expect(result).to eq(
        'studentteam1' => %w(teststudent1 teststudent2)
      )
    end
  end
end
