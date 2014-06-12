module TeachersPet
  module Actions
    class CreateRepos < Base
      def read_info
        @repository = self.repository
        @organization = self.organization
        @public_repos = self.public?
      end

      def load_files
        @students = self.read_students_file
      end

      def create
        # create a repo for each student
        self.init_client

        org_hash = @client.organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:login]}"

        # Load the teams - there should be one team per student.
        # Repositories are given permissions by teams
        org_teams = get_teams_by_name(@organization)
        # For each student - create a repository, and give permissions to their "team"
        # The repository name is teamName-repository
        puts "\nCreating assignment repositories for students..."
        @students.keys.sort.each do |student|
          unless org_teams.key?(student)
            puts("  ** ERROR ** - no team for #{student}")
            next
          end
          repo_name = "#{student}-#{@repository}"

          if repository?(@organization, repo_name)
            puts " --> Already exists, skipping '#{repo_name}'"
            next
          end

          puts " --> Creating '#{repo_name}' public? #{@public_repos}"
          @client.create_repository(repo_name,
            description: "#{@repository} created for #{student}",
            private: !@public_repos,
            has_issues: true,
            has_wiki: false,
            has_downloads: false,
            organization: @organization,
            team_id: org_teams[student][:id]
          )
        end
      end

      def run
        self.read_info
        self.load_files
        self.create
      end
    end
  end
end
