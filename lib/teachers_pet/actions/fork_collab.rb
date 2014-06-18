module TeachersPet
  module Actions
    class ForkCollab < Base
      def repository
        self.options[:repository]
      end

      def get_forks
        self.client.forks(self.repository)
      end

      def promote
        self.init_client
        forks = self.get_forks
        forks.each do |fork|
          login = fork.owner.login
          if fork.owner.type == "User"
            unless self.options[:dry_run]
              result = self.client.add_collab(self.repository, login)
            end
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
