require 'delegate'

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

    def create_team(organization, name)
      puts "Creating team @#{organization}/#{name} ..."
      super(organization,
        name: name,
        permission: 'push'
      )
    end

    def add_users_to_team(organization, team, usernames)
      # Minor optimization, mostly for testing
      if usernames.any?
        team_members = self.get_team_member_logins(team[:id])
        usernames.each do |username|
          if team_members.include?(username)
            puts " -> @#{username} is already on @#{organization}/#{team[:name]}"
          else
            # https://github.com/octokit/octokit.rb/pull/518
            self.add_team_membership(team[:id], username, accept: 'application/vnd.github.the-wasp-preview+json')
            puts " -> @#{username} has been added to @#{organization}/#{team[:name]}"
          end
        end
      end
    end

    def milestone?(organization, repo, milestone)
      begin
        self.milestone("#{organization}/#{repo}", milestone)
      rescue
        return false
      end
    end
  end
end
