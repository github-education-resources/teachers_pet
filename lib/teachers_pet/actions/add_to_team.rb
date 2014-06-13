module TeachersPet
  module Actions
    class AddToTeam < Base
      def read_members_file
        file = self.members
        puts "Loading members to add:"
        read_file(file).keys
      end

      def team_name
        file = self.members
        File.basename(file, File.extname(file))
      end

      def team
        teams_by_name = self.client.existing_teams_by_name(self.organization)
        teams_by_name[self.team_name] || self.client.create_team(self.organization, team_name)
      end

      def add_members_to_owners
        member_list = self.read_members_file
        self.client.add_users_to_team(organization, self.team, member_list)
      end

      def run
        self.init_client
        self.add_members_to_owners
      end
    end
  end
end
