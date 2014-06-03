# Create a team from all users named in a students file

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..')

require 'set'
require 'rubygems'
require 'highline/question'
require 'highline/compatibility'

require 'teachers_pet/actions/base'

module TeachersPet
  module Actions
    class StudentsTeam < Base
      def read_info
        @organization = ask("What is the organization name?") { |q| q.default = TeachersPet::Configuration.organization }
        @student_file = self.get_students_file_path
      end

      def load_files
        @students = read_file(@student_file, 'Students')
      end

      def update_team
        self.init_client
        
        all_team_name='Students'
        confirm("Add #{@students.size} members to '#{all_team_name}' team?")

        # Get current members of org team
        existing = Hash.new
        teams = self.get_teams_by_name(@organization)
        studentsteam = teams[all_team_name] || false
        unless studentsteam
          puts "\nCreating team #{all_team_name}..."
          @client.create_team(@organization,
            {
              :name => all_team_name,
              :permission => 'push'
            })
          studentsteam = self.get_teams_by_name(@organizaiton)['Students']
        end
        
        # Find and add new students to the org team
        all_students = Set.new
        @students.each do |team, members|
          all_students.merge(members)
        end
        all_team_members = Set.new(self.get_team_member_logins(studentsteam[:id]))
        new_students = all_students - all_team_members
        old_students = all_team_members - all_students
        
        puts "\nMembers of '#{studentsteam[:name]}':"
        all_team_members.each do |member|
          puts " -> #{member}"
        end
        puts "\nAdding members:"
        new_students.each do |student|
          @client.add_team_member(studentsteam[:id], student)
          puts " -> #{student}"
        end
        puts "\nMembers not mentioned:"
        old_students.each do |student|
          puts " -> #{student}"
        end
       
        puts "\n#{all_team_members.length} previous members in '#{studentsteam[:name]}'."
        puts "#{new_students.length} members added."
        puts "#{(all_students - new_students).length} skipped."
      end

      def run
        self.read_info
        self.load_files
        self.update_team
      end
    end
  end
end
