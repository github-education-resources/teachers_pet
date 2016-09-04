module TeachersPet
  module Actions
    class OpenIssue < Base
      def read_info
        @repository = self.options[:repository]
        @organization = self.options[:organization]

        @issue = {
          title: self.options[:title],
          options: {
            labels: self.options[:labels]
          }
        }
        @issue_file = self.options[:body]
        @path_to_file = self.options[:path]

      end

      def load_files
        @students = self.read_students_file
        if !@issue_file.nil?
          @issue[:body] = File.open(@issue_file).read
        end
      end

      def create
        # confirm("Create issue '#{@issue[:title]}' in #{@students.keys.size} student repositories - '#{@repository}'?")
        self.init_client

        org_hash = self.client.organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:login]}"

        org_teams = self.client.get_teams_by_name(@organization)

        puts "\nCreating issue in repositories..."
        @students.keys.sort.each do |student|
          unless org_teams.key?(student)
            puts("  ** ERROR ** - no team for #{student}")
            next
          end
          repo_name = "#{student}-#{@repository}"

          unless self.client.repository?(@organization, repo_name)
            puts " --> Repository not found, skipping '#{repo_name}'"
            next
          end

          if @issue_file.nil?
            @issue[:body] = File.open(@path_to_file + student+".md").read
          end
          # Create the issue with octokit
          self.client.create_issue("#{@organization}/#{repo_name}", @issue[:title], @issue[:body], @issue[:options])
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
