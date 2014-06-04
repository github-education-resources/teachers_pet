require_relative 'non_interactive'

module TeachersPet
  module Actions
    class ForkCollab < NonInteractive
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
            result = @client.add_collab(self.options[:repository], login)
            puts "#{login} - #{result}"
          else
            puts "#{login} - false (Organization)"
          end
        end
      end

      def run
        self.promote
      end
    end
  end
end
