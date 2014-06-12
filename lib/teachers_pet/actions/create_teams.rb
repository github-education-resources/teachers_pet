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
        self.create_student_teams
        self.add_instructors_to_owners
      end

      def create_student_teams
        teams_by_name = self.existing_teams_by_name

        @students.each do |key, value|
          if value
            # Create one team per group of students
            team_name = key
            usernames = value
          else
            # Create a team with the same name as the student, with that person as the only member
            team_name = key
            usernames = [value]
          end

          team = teams_by_name[team_name]
          if team
            puts "Team @#{organization}/#{team_name} already exists."
          else
            team = self.create_team(team_name)
          end
          self.add_users_to_team(team, usernames)
        end
      end

      def add_instructors_to_owners
        owners = self.existing_teams_by_name['Owners']
        self.add_users_to_team(owners, @instructors.keys)
      end

      def create_team(name)
        puts "Creating team @#{organization}/#{name} ..."
        @client.create_team(@organization,
          name: name,
          permission: 'push'
        )
      end

      def existing_teams_by_name
        unless @existing_teams_by_name
          @existing_teams_by_name = Hash.new
          teams = @client.organization_teams(@organization)
          teams.each do |team|
            @existing_teams_by_name[team[:name]] = team
          end
        end

        @existing_teams_by_name
      end

      def add_users_to_team(team, usernames)
        # Minor optimization, mostly for testing
        if usernames.any?
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
      end

      def run
        self.read_info
        self.load_files
        self.create
      end
    end
  end
end
