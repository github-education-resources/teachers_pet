# Author: Mike Helmick
# Script to create assignment repositories for students under the appropriate organization

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..')

require 'rubygems'
require 'highline/question'
require 'highline/import'
require 'highline/compatibility'
require 'octokit'
require 'teachers_pet/actions/base'

module TeachersPet
  module Actions
    class CreateRepos < Base
      def initialize()
      end

      def read_info()
        @repository = ask('What repository name should be created for each student?') { |q| q.validate = /\w+/ }
        @organization = ask("What is the organization name?") { |q| q.default = TeachersPet::Configuration.organization }
        @student_file = ask('What is the name of the list of student IDs') { |q| q.default = TeachersPet::Configuration.studentsFile }
        @instructor_file = ask('What is the name of the list of instructor IDs') { |q| q.default = TeachersPet::Configuration.instructorsFile }
        @add_init_files = confirm('Add .gitignore and README.md files? (skip this if you are pushing starter files.)', false)
      end

      def load_files()
        @students = read_file(@student_file, 'Students')
        @instructors = read_file(@instructor_file, 'Instructors')
      end

      def create
        confirm("Create #{@students.keys.size} repositories for students and give access to instructors?")

        # create a repo for each student
        init_client()

        org_hash = read_organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:login]}"

        # Load the teams - there should be one team per student.
        # Repositories are given permissions by teams
        org_teams = get_teams_by_name(@organization)
        # For each student - create a repository, and give permissions to their "team"
        # The repository name is teamName-repository
        puts "\nCreating assignment repositories for students..."
        @students.keys.sort.each do |student|
          unless org_teams.key?(student)
            puts("  ** ERROR ** - no team for #{student}")
            next
          end
          repo_name = "#{student}-#{@repository}"

          if repository?(@organization, repo_name)
            puts " --> Already exists, skipping '#{repo_name}'"
            next
          end

          git_ignore_template = "C++" ## This is specific to my current class, you'll want to change
          git_ignore_template = '' unless @add_init_files
          puts " --> Creating '#{repo_name}'"
          @client.create_repository(repo_name,
              {
                :description => "#{@repository} created for #{student}",
                :private => !TeachersPet::Configuration.reposPublic, ## Current default, repositories are private to the student & instructors
                :has_issues => true, # seems like a resonable default
                :has_wiki => false,
                :has_downloads => false,
                :organization => @organization,
                :team_id => org_teams[student][:id],
                :auto_init => @add_init_files,
                :gitignore_template => git_ignore_template
              })
        end
      end
    end
  end
end
