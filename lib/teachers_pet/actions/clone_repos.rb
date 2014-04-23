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
      def read_args(args)
        @repository = args[:repo]
        @organization = args[:org]
        @student_file = args[:students]
        @authmethod = args[:auth]
      end

      def load_files
        @students = read_file(@student_file, 'Students')
      end

      def clone(args)
        cloneMethod = args[:clone]

        confirm("Clone all repositories?")

        # create a repo for each student
        self.init_client(args)

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

      def run(args)
        self.read_args(args)
        self.load_files
        self.clone(args)
      end
    end
  end
end
