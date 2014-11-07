module TeachersPet
  module Actions
    class CreateStudentTeams < Base
      def create_student_teams
        org_login = self.options[:organization]
        teams_by_name = self.client.existing_teams_by_name(org_login)

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
            puts "Team @#{org_login}/#{team_name} already exists."
          else
            team = self.client.create_team(org_login, team_name)
          end
          self.client.add_users_to_team(org_login, team, usernames)
        end
      end

      def run
        self.init_client
        self.create_student_teams
      end
    end
  end
end
