require 'travis/pro'
require 'travis/tools/github'

module TeachersPet
  module Actions
    class CreateRepos < Base
      def read_info
        @repository = self.options[:repository]
        @organization = self.options[:organization]
        @public_repos = self.options[:public]
      end

      def load_files
        @students = self.read_students_file
      end

      def create
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
        puts "\nCreating assignment repositories for students..."
        @students.keys.sort.each do |student|
          unless org_teams.key?(student)
            puts("  ** ERROR ** - no team for #{student}")
            next
          end
          repo_name = "#{student}-#{@repository}"

          if self.client.repository?(@organization, repo_name)
            puts " --> Already exists, skipping '#{repo_name}'"
            next
          end
		  
          puts " --> Creating '#{repo_name}' public? #{@public_repos}"
          self.client.create_repository(repo_name,
            description: "#{@repository} created for #{student}",
            private: !@public_repos,
            has_issues: true,
            has_wiki: false,
            has_downloads: false,
            organization: @organization,
            team_id: org_teams[student][:id]
          )

		  # Travis stuff:
		  #  authenticate
		  #github = Travis::Tools::Github.new(auto_token: true, auto_password: true) do |g|
          #  g.ask_login    = -> { print("GitHub login:"); STDIN.gets }
          #  g.ask_password = -> { print("Password:"); STDIN.gets }
          #  g.ask_otp      = -> { print("Two-factor token:"); STDIN.gets }
          #end

          #github.with_token do |token|
          #  Travis::Pro.github_auth(token)
          #end
          travis_client = Travis::Client.new(uri: Travis::Client::PRO_URI)
          travis_client.github_auth(self.options[:token])
		  # Make sure Travis knows about the new repo
		  #  Need to sleep a bit, else Travis can't find the new repo
		  travis_client.user.sync
		  sleep 5

		  # Enable Travis-CI for the repository
		  travis_repo = travis_client.repo("#{@organization}/#{repo_name}")
		  travis_repo.enable
          puts " --> Activated Travis for #{travis_repo.slug}"
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
