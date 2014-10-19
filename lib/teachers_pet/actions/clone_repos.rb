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

      def clone_command(username)
        path = self.repo_path(username)
        "git clone #{self.clone_endpoint}#{path}.git #{@repository}/#{username}"
      end

      def clone(username)
        command = self.clone_command(username)
        puts " --> Cloning: '#{command}'"
        self.execute(command)
      end

      def repo_owner(username)
        if self.options[:forks]
          username
        else
          @organization
        end
      end

      def repo_name(username)
        if self.options[:forks]
          @repository
        else
          "#{username}-#{@repository}"
        end
      end

      def repo_path(username)
        name = self.repo_name(username)
        owner = self.repo_owner(username)
        "#{owner}/#{name}"
      end

      def clone_student(username)
        if self.client.repository?(self.repo_owner(username), self.repo_name(username))
          self.clone(username)
        else
          path = self.repo_path(username)
          puts " ** ERROR ** - Can't find expected repository '#{path}'"
        end
      end

      def verify_org_exists
        org_hash = self.client.organization(@organization)
        if org_hash.nil?
          abort('Organization could not be found')
        end
        puts "Found organization at: #{org_hash[:url]}"
      end

      def clone_all
        self.init_client

        unless self.options[:forks]
          self.verify_org_exists
        end

        self.execute("mkdir -p #{@repository}")

        # For each student - pull the repository if it exists
        puts "\nCloning assignment repositories for students..."
        self.students.each do |student|
          self.clone_student(student)
        end
      end

      def run
        self.read_info
        self.clone_all
      end
    end
  end
end
