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
        # create a repo for each student
        self.init_client

        org_hash = self.client.organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:login]}"

        # Load the teams - there should be one team per student.
        # Repositories are given permissions by teams
        org_teams = self.client.get_teams_by_name(@organization)
        # For each student - create a repository, and give permissions to their "team"
        # The repository name is teamName-repository
        puts "\nDeleting students' assignment repositories..."
        @students.keys.sort.each do |student|
          unless org_teams.key?(student)
            puts("  ** ERROR ** - no team for #{student}")
            next
          end
          repo_name = "#{student}_#{@repository}"

          unless self.client.repository?(@organization, repo_name)
            puts " --> Does not exist, skipping '#{repo_name}'"
            next
          end

          ######################
          # Only managed to get this working only with a 
          # Personal access token with a 'delete_repo' scope
		  # Works with password now!
          ######################
          puts " --> Deleting '#{repo_name}'"
          self.client.delete_repository("#{@organization}/#{repo_name}")
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
