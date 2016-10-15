module TeachersPet
  module Actions
    class DeleteRepos < Base
      def read_info
        @repository = self.options[:repository]
        @organization = self.options[:organization]
      end

      def load_files
        @students = self.read_students_file
      end

      def delete
        # delete specified repo of each student
        self.init_client
        org_hash = self.client.organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:login]}"
        puts "\nDeleting specified repositories of students..."
        @students.keys.sort.each do |student|
          repo_name = "#{student}-#{@repository}"
          if self.client.repository?(@organization, repo_name)
            puts " --> Deleting '#{repo_name}'"
            if self.client.delete_repository(@organization + '/' + repo_name)
              puts "#{repo_name} deleted successfully"
            else
              puts "Failed, please make sure you have permission on this repo"
            end
          else
            puts " --> Repository '#{student}-#{@repository}' not found"
          end
        end
      end

      def run
        self.read_info
        self.load_files
        self.delete
      end
    end
  end
end
