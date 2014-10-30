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

        def repository_name
          @repository_name ||= self.hsh.html_url.match(%r{^https://github.com/[^/]+/([^/]+)/pull/\d+$})[1]
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
          pr_urls = prs.map(&:html_url)
          row << pr_urls.join(', ')
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
