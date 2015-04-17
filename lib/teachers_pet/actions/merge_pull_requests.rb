module TeachersPet
  module Actions
    class MergePullRequests < Base
      def run
        repository = self.options[:repository]

        open_pull_requests = self.client.pull_requests(repository, state: 'open')
        open_pull_requests.each do |pr|
          print "Merging #{pr.html_url}..."
          client.merge_pull_request(repository, pr.number)
          puts "done"
        end
      end
    end
  end
end
