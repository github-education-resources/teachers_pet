# Opens a single issue in each repository.  The body of the issue is loaded
# from a file and the user is prompted for the title.

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..')

require 'rubygems'
require 'highline/question'
require 'highline/import'
require 'teachers_pet/actions/base'

module TeachersPet
  module Actions
    class OpenIssue < Base
      def read_info
        @repository = ask("What repository will the issue be raised in?") { |q| q.validate = /\w+/ }
        @organization = ask("What is the organization name?") { |q| q.default = TeachersPet::Configuration.organization }
        
        @issue = {}
        @issue[:title] = ask("What is the title of the issue?")
        @issue_file = ask("What is the path to the file containing the issue body?")
        
        # Add labels to issue
        options = {}
        options[:labels] = ask("Optionally add any labels, seperated by commas:")
        @issue[:options] = options

        @student_file = self.get_students_file_path
        @instructor_file = self.get_instructors_file_path
      end

      def load_files
        @students = read_file(@student_file, 'Students')
        @instructors = read_file(@instructor_file, 'Instructors')
        @issue[:body] = File.open(@issue_file).read
      end

      def create
        confirm("Create issue '#{@issue[:title]}' in #{@students.keys.size} student repositories - '#{@repository}'?")
        self.init_client

        org_hash = read_organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:login]}"

        org_teams = get_teams_by_name(@organization)
        
        puts "\nCreating issue in repositories..."
        @students.keys.sort.each do |student|
          unless org_teams.key?(student)
            puts("  ** ERROR ** - no team for #{student}")
            next
          end
          repo_name = "#{student}-#{@repository}"

          unless repository?(@organization, repo_name)
            puts " --> Repository not found, skipping '#{repo_name}'"
            next
          end

          # Create the issue with octokit
          @client.create_issue("#{@organization}/#{repo_name}", @issue[:title], @issue[:body], @issue[:options])
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
