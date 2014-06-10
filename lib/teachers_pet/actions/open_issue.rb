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
      end

      def load_files
        @students = self.read_students_file
        @instructors = self.read_instructors_file
        @issue[:body] = File.open(@issue_file).read
      end

      def create
        # confirm("Create issue '#{@issue[:title]}' in #{@students.keys.size} student repositories - '#{@repository}'?")
        self.init_client

        org_hash = @client.organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:login]}"

        org_teams = get_teams_by_name(@organization)

        puts "\nCreating issue in repositories..."
        @students.keys.sort.each do |student|
          unless org_teams.key?(student)
            puts("  ** ERROR ** - no team for #{student}")
            next
          end
          repo_name = "#{student}-#{@repository}"

          unless repository?(@organization, repo_name)
            puts " --> Repository not found, skipping '#{repo_name}'"
            next
          end

          # Create the issue with octokit
          @client.create_issue("#{@organization}/#{repo_name}", @issue[:title], @issue[:body], @issue[:options])
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
