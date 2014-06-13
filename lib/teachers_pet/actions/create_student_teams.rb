module TeachersPet
  module Actions
    class CreateStudentTeams < Base
      def create_student_teams
        teams_by_name = self.client.existing_teams_by_name(self.organization)

        students_list = self.read_students_file
        students_list.each do |key, value|
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
            team = self.client.create_team(organization, team_name)
          end
          self.client.add_users_to_team(organization, team, usernames)
        end
      end

      def run
        self.init_client
        self.create_student_teams
      end
    end
  end
end
