require 'spec_helper'

describe TeachersPet::Actions::Base do
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
