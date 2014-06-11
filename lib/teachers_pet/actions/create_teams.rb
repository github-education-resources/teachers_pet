module TeachersPet
  module Actions
    class CreateTeams < Base
      def read_info
        @organization = self.organization
      end

      def load_files
        @students = self.read_students_file
        @instructors = self.read_instructors_file
      end

      def create
        self.init_client
        teams_by_name = self.existing_teams_by_name

        @students.keys.each do |team_name|
          if teams_by_name[team_name]
            puts "Team @#{organization}/#{team_name} already exists."
          else
            teams_by_name[team_name] = self.create_team(team_name)
          end
        end

        puts "\nAdjusting team memberships"
        teams_by_name.each do |team_name, team|
          self.add_members(team)
        end
      end

      def create_team(name)
        puts "Creating team @#{organization}/#{name} ..."
        @client.create_team(@organization,
          name: name,
          permission: 'push'
        )
      end

      def existing_teams_by_name
        teams_by_name = Hash.new
        teams = @client.organization_teams(@organization)
        teams.each do |team|
          teams_by_name[team[:name]] = team
        end
        teams_by_name
      end

      def add_users_to_team(team, usernames)
        team_members = get_team_member_logins(team[:id])
        usernames.each do |username|
          if team_members.include?(username)
            puts " -> @#{username} is already on @#{organization}/#{team[:name]}"
          else
            @client.add_team_member(team[:id], username)
            puts " -> @#{username} has been added to @#{organization}/#{team[:name]}"
          end
        end
      end

      def add_members(team)
        if team[:name].eql?('Owners')
          self.add_users_to_team(team, @instructors.keys)
        elsif @students.key?(team[:name])
          self.add_users_to_team(team, @students[team[:name]])
        else
          puts "*** Team @#{organization}/#{team[:name]} does not match any students, ignoring. ***"
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
