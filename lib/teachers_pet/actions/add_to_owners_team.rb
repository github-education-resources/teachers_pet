module TeachersPet
  module Actions
    class AddToOwnersTeam < Base
      def read_members_file
        file = self.members
        puts "Loading members to add:"
        read_file(file).keys
      end

      def add_members_to_owners
        owners = self.client.existing_teams_by_name(self.organization)['Owners']
        member_list = self.read_members_file
        self.client.add_users_to_team(organization, owners, member_list)
      end

      def run
        self.init_client
        self.add_members_to_owners
      end
    end
  end
end
