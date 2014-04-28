$LOAD_PATH << File.join(File.dirname(__FILE__), '..', '..')

require 'rubygems'
require 'highline/question'
require 'highline/import'
require 'highline/compatibility'
require 'octokit'
require 'teachers_pet/actions/base'

module TeachersPet
  module Actions
    class ForkCollab < Base
      def read_info
        @repository = ask("Which repository? (owner/repo)")
      end

      def get_forks
        @client.forks(@repository)
      end

      def promote
        self.init_client

        forks = self.get_forks

        confirm("Are you sure you want to add #{forks.count} users as collaborators on '#{@repository}'?")

        forks.each do |fork|
          login = fork.owner.login
          if fork.owner.type == "User"
            result = @client.add_collab(@repository, login)
            puts "#{login} - #{result}"
          else
            puts "#{login} - false (Organization)"
          end
        end
      end

      def run
        self.read_info
        self.promote
      end
    end
  end
end
