require 'csv'

module TeachersPet
  module Actions
    class PullRequests < Base

      # decorator
      class PullRequest
        attr_accessor :hsh

        def initialize(hash)
          @hsh = hash
        end

        def matches
          @matches ||= self.hsh.html_url.match(%r{^https://github.com/[^/]+/([^/]+)/pull/\d+$})
        end

        def repository_name
          self.matches[1]
        end

        def closed?
          self.state == 'closed'
        end

        def method_missing(meth)
          self.hsh.send(meth)
        end
      end


      def org_pull_request_results
        self.client.search_issues("type:pr user:#{self.options[:organization]}")
      end

      # returns an Array of PullRequests
      def org_pull_requests
        @org_pull_requests ||= self.org_pull_request_results.items.map{|pr| PullRequest.new(pr) }
      end

      def pull_requests_by_repo_by_login
        results = {}
        self.org_pull_requests.each do |pr|
          login = pr.user.login
          repo = pr.repository_name

          results[login] ||= {}
          results[login][repo] ||= []
          results[login][repo] << pr
        end

        results
      end

      def repositories
        self.client.repositories(self.options[:organization])
      end

      def repository_columns
        @repository_columns ||= self.repositories.map(&:name).sort
      end

      def headers
        %w(Login).concat(self.repository_columns)
      end

      def generate_row(login, pull_requests_by_repo)
        row = [login]
        # list the repositories in a consistent order
        self.repository_columns.each do |repo|
          prs = pull_requests_by_repo[repo] || []

          # get their newest PR, that's preferably still open
          prs = prs.sort_by do |pr|
            state = pr.closed? ? 0 : 1
            [state, pr.number]
          end
          pr = prs.last

          url = pr ? pr.html_url : nil
          row << url
        end

        row
      end

      def run
        self.init_client

        filename = self.options[:output]
        CSV.open(filename, 'wb') do |csv|
          csv << self.headers
          self.pull_requests_by_repo_by_login.each do |login, pull_requests_by_repo|
            row = self.generate_row(login, pull_requests_by_repo)
            csv << row
          end
        end

        puts "Wrote to #{filename}."
      end
    end
  end
end
