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
        self.init_client
        forks = self.get_forks

        # TODO configurable filename
        CSV.open('./students.csv', 'wb') do |csv|
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
