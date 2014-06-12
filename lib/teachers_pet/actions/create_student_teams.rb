module TeachersPet
  module Actions
    class CreateStudentTeams < Base
      def read_info
        @organization = self.organization
      end

      def load_files
        @students = self.read_students_file
      end

      def create
        self.init_client
        self.create_student_teams
      end

      def create_student_teams
        teams_by_name = self.client.existing_teams_by_name(@organization)

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
