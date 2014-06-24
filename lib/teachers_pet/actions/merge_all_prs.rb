module TeachersPet
  module Actions
    class MergeAllOpenPrs < Base
      def read_info
        @repository = self.repository
        @organization = self.repository
      end

      def merge_all
        self.init_client

        org_hash = self.client.organization(@organization)
        abort('Organization could not be found') if org_hash.nil?
        puts "Found organization at: #{org_hash[:url]}"

        repo_hash = self.client.repository(@repository)
        abort('Repository could not be found') if repo_hash.nil?
        puts "Found repository at: #{repo_hash[:url]}"

        open_pull_requests = self.client.pull_requests("#{@organization}/#{@repository}", state: 'open')

        open_pull_requests.each do |pr|
          print "Merging #{pr.html.url}..."
          client.merge_pull_request("#{@organization}/#{@repository}", pr.number)
          puts "done"
        end
      end

      def run
        self.read_info
        self.merge_all
      end
    end
  end
end
