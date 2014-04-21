# Author: Mike Helmick
# Clones all student repositories for a particular assignment
#
# Currently this will clone all student repositories into the current

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..')

require 'rubygems'
require 'highline/question'
require 'highline/import'
require 'highline/compatibility'
require 'octokit'
require 'teachers_pet/actions/base'

module TeachersPet
  module Actions
    class CloneRepos < Base
      def read_info
        @repository = ask('What repository name should be cloned for each student?') { |q| q.validate = /\w+/ }
        @organization = ask("What is the organization name?") { |q| q.default = TeachersPet::Configuration.organization }
        @student_file = self.get_students_file_path
      end

      def load_files
        @students = read_file(@student_file, 'Students')
      end

      def get_clone_method
        cloneMethod = 'https'
        choose do |menu|
          menu.prompt = "Clone via? "
          menu.choice :ssh do
            cloneMethod = 'ssh'
          end
          menu.choice :https do
            cloneMethod = 'https'
          end
        end

        cloneMethod
      end

      def create
        cloneMethod = self.get_clone_method

        confirm("Clone all repositories?")

        # create a repo for each student
        self.init_client

        org_hash = read_organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:url]}"

        # Load the teams - there should be one team per student.
        org_teams = get_teams_by_name(@organization)
        # For each student - pull the repository if it exists
        puts "\nCloning assignment repositories for students..."
        @students.keys.each do |student|
          unless org_teams.key?(student)
            puts("  ** ERROR ** - no team for #{student}")
            next
          end
          repo_name = "#{student}-#{@repository}"

          unless repository?(@organization, repo_name)
            puts " ** ERROR ** - Can't find expected repository '#{repo_name}'"
            next
          end


          sshEndpoint = @web_endpoint.gsub("https://","git@").gsub("/",":")
          command = "git clone #{sshEndpoint}#{@organization}/#{repo_name}.git"
          if cloneMethod.eql?('https')
            command = "git clone #{@web_endpoint}#{@organization}/#{repo_name}.git"
          end
          puts " --> Cloning: '#{command}'"
          self.execute(command)
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
