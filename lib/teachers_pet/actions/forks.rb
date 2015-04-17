require 'csv'

module TeachersPet
  module Actions
    class Forks < Base
      def repository
        self.options[:repository]
      end

      def get_forks
        self.client.forks(self.repository)
      end

      def run
        forks = self.get_forks

        CSV.open(self.options[:output], 'wb') do |csv|
          forks.each do |fork|
            login = fork.owner.login
            if fork.owner.type == "User"
              csv << [login]
            else
              puts "Ignoring organization: @#{login}"
            end
          end
        end
      end
    end
  end
end
