module TeachersPet
  module Actions
    class AddToTeam < Base
      def team_name
        file = self.options[:members]
        File.basename(file, File.extname(file))
      end

      def team
        org_login = self.options[:organization]
        teams_by_name = self.client.existing_teams_by_name(org_login)
        teams_by_name[self.team_name] || self.client.create_team(org_login, team_name)
      end

      def add_members
        member_list = self.read_members_file
        self.client.add_users_to_team(self.options[:organization], self.team, member_list)
      end

      def run
        self.init_client
        self.add_members
      end
    end
  end
end
