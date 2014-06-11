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
        existing = self.existing_teams_by_name

        puts "\nDetermining which students need teams created..."
        todo = Hash.new
        @students.keys.each do |team_name|
          if existing[team_name].nil?
            puts " -> #{team_name}"
            todo[team_name] = true
          end
        end

        if todo.empty?
          puts "\nAll teams exist"
        else
          puts "\nCreating team..."
          todo.keys.each do |team_name|
            puts " -> '#{team_name}' ..."
            team = @client.create_team(@organization,
              name: team_name,
              permission: 'push'
            )
            existing[team_name] = team
          end
        end

        puts "\nAdjusting team memberships"
        existing.each do |team_name, team|
          self.add_members(team)
        end
      end

      def existing_teams_by_name
        teams_by_name = Hash.new
        teams = @client.organization_teams(@organization)
        teams.each do |team|
          teams_by_name[team[:name]] = team
        end
        teams_by_name
      end

      def add_members(team)
        team_members = get_team_member_logins(team[:id])
        if team[:name].eql?('Owners')
          puts "*** OWNERS *** - Ensuring instructors are owners"
          @instructors.keys.each do |instructor|
            unless team_members.include?(instructor)
              @client.add_team_member(team[:id], instructor)
              puts " -> '#{instructor}' has been made an owner for this course"
            else
              puts " -> '#{instructor}' is already an owner"
            end
          end
        elsif @students.key?(team[:name])
          puts "Validating membership for team '#{team[:name]}'"
          # If there isn't a team member that is the same name as the team, and we already know
          # there is a student with the same name, add that student to the team.
          #unless team_members.include?(team[:name])
          @students[team[:name]].each do |student|
            puts "  -> Adding '#{team[:name]}' to the team"
            @client.add_team_member(team[:id], student)
          end
          # Originally, instructors were added to the student's team, but that isn't needed
          # since instructors are addded to the Owners team that can see all repositories.
        else
          puts "*** Team name '#{team[:name]}' does not match any students, ignoring. ***"
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
