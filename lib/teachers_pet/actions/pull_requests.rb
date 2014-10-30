require 'csv'

module TeachersPet
  module Actions
    class PullRequests < Base
      def repositories
        self.client.repositories(self.options[:organization])
      end

      def org_pull_requests
        @org_pull_requests ||= self.client.search_issues("type:pr user:#{self.options[:organization]}").items.to_a
      end

      def repository_name(pull_request_url)
        pull_request_url.match(%r{^https://github.com/[^/]+/([^/]+)/pull/\d+$})[1]
      end

      def pull_requests_by_repo_by_login
        results = {}
        self.org_pull_requests.each do |pr|
          login = pr.user.login
          repo = self.repository_name(pr.html_url)

          results[login] ||= {}
          results[login][repo] ||= []
          results[login][repo] << pr
        end

        results
      end

      def repository_names
        @repository_names ||= self.org_pull_requests.map{|pr| self.repository_name(pr.html_url) }.uniq
      end

      def repository_columns
        @repository_columns ||= self.repository_names.sort
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

        CSV.open(self.options[:output], 'wb') do |csv|
          csv << self.headers
          self.pull_requests_by_repo_by_login.each do |login, pull_requests_by_repo|
            row = self.generate_row(login, pull_requests_by_repo)
            csv << row
          end
        end
      end
    end
  end
end
