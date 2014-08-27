module TeachersPet
  module Actions
    class CloneRepos < Base
      def read_info
        @repository = self.options[:repository]
        @organization = self.options[:organization]
      end

      def load_files
        @students = self.read_students_file
      end

      def get_clone_method
        self.options[:clone_method]
      end

      def create
        cloneMethod = self.get_clone_method

        # create a repo for each student
        self.init_client

        org_hash = self.client.organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:url]}"

        # Load the teams - there should be one team per student.
        org_teams = self.client.get_teams_by_name(@organization)
        # For each student - pull the repository if it exists
        puts "\nCloning assignment repositories for students..."
        @students.keys.each do |student|
          unless org_teams.key?(student)
            puts("  ** ERROR ** - no team for #{student}")
            next
          end
          repo_name = "#{student}-#{@repository}"

          unless self.client.repository?(@organization, repo_name)
            puts " ** ERROR ** - Can't find expected repository '#{repo_name}'"
            next
          end

          web = self.options[:web]
          sshEndpoint = web.gsub("https://","git@").gsub("/",":")
          command = "git clone #{sshEndpoint}#{@organization}/#{repo_name}.git"
          if cloneMethod.eql?('https')
            command = "git clone #{web}#{@organization}/#{repo_name}.git"
          end
          puts " --> Cloning: '#{command}'"
          system(command)
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
