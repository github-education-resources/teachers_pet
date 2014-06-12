module TeachersPet
  class ClientDecorator < SimpleDelegator
    def repository?(organization, repo_name)
      begin
        self.repository("#{organization}/#{repo_name}")
      rescue
        return false
      end
    end

    def get_teams_by_name(organization)
      org_teams = self.organization_teams(organization)
      teams = Hash.new
      org_teams.each do |team|
        teams[team[:name]] = team
      end
      return teams
    end

    def get_team_member_logins(team_id)
      self.team_members(team_id).map do |member|
        member[:login]
      end
    end

    def existing_teams_by_name(organization)
      results = Hash.new
      teams = self.organization_teams(organization)
      teams.each do |team|
        results[team[:name]] = team
      end

      results
    end
  end
end
