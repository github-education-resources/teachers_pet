require_relative 'non_interactive'

module TeachersPet
  module Actions
    class ForkCollab < NonInteractive
      def repository
        self.options[:repository]
      end

      def get_forks
        @client.forks(self.repository)
      end

      def promote
        self.init_client
        forks = self.get_forks
        forks.each do |fork|
          login = fork.owner.login
          if fork.owner.type == "User"
            result = @client.add_collab(self.repository, login)
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
