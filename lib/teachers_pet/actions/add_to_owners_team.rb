module TeachersPet
  module Actions
    class AddToOwnersTeam < Base
      def read_info
        @organization = self.organization
      end

      def read_members_file
        file = self.members
        puts "Loading members to add:"
        read_file(file)
      end

      def load_files
        @members = self.read_members_file
      end

      def create
        self.init_client
        self.add_members_to_owners
      end

      def add_members_to_owners
        owners = self.client.existing_teams_by_name(@organization)['Owners']
        self.add_users_to_team(owners, @members.keys)
      end

      def create_team(name)
        puts "Creating team @#{organization}/#{name} ..."
        self.client.create_team(@organization,
          name: name,
          permission: 'push'
        )
      end

      def add_users_to_team(team, usernames)
        # Minor optimization, mostly for testing
        if usernames.any?
          team_members = self.client.get_team_member_logins(team[:id])
          usernames.each do |username|
            if team_members.include?(username)
              puts " -> @#{username} is already on @#{organization}/#{team[:name]}"
            else
              self.client.add_team_member(team[:id], username)
              puts " -> @#{username} has been added to @#{organization}/#{team[:name]}"
            end
          end
        end
      end

      def run
        self.read_info
        self.load_files
        self.create
      end
    end
  end
end
