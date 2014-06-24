module TeachersPet
  module Actions
    class AddCollaborators < Base
      def repository
        self.options[:repository]
      end

      def run
        self.init_client

        members = self.read_members_file
        members.each do |login|
          unless self.options[:dry_run]
            result = self.client.add_collab(self.repository, login)
          end
          puts "#{login} - #{result}"
        end
      end
    end
  end
end
