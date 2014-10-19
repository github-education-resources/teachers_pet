module TeachersPet
  module Actions
    class CloneRepos < Base
      def read_info
        @repository = self.options[:repository]
        @organization = self.options[:organization]
      end

      def students
        @students ||= self.read_students_file.keys
      end

      def org_teams
        # Load the teams - there should be one team per student.
        @org_teams ||= self.client.get_teams_by_name(@organization)
      end

      def web_endpoint
        self.options[:web]
      end

      def ssh_endpoint
        @ssh_endpoint ||= self.web_endpoint.gsub("https://","git@").gsub("/",":")
      end

      def clone_method
        self.options[:clone_method]
      end

      def clone_endpoint
        if self.clone_method == 'https'
          self.web_endpoint
        else
          self.ssh_endpoint
        end
      end

      def clone_command(repo_name)
        "git clone #{self.clone_endpoint}#{@organization}/#{repo_name}.git"
      end

      def clone(repo_name)
        command = self.clone_command(repo_name)
        puts " --> Cloning: '#{command}'"
        self.execute(command)
      end

      def clone_all
        # create a repo for each student
        self.init_client

        org_hash = self.client.organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:url]}"

        # For each student - pull the repository if it exists
        puts "\nCloning assignment repositories for students..."
        self.students.each do |student|
          unless self.org_teams.key?(student)
            puts("  ** ERROR ** - no team for #{student}")
            next
          end

          repo_name = "#{student}-#{@repository}"

          unless self.client.repository?(@organization, repo_name)
            puts " ** ERROR ** - Can't find expected repository '#{repo_name}'"
            next
          end

          self.clone(repo_name)
        end
      end

      def run
        self.read_info
        self.clone_all
      end
    end
  end
end
