module TeachersPet
  class Cli
    option :organization, required: true
    option :output, banner: 'PATH', default: 'pull_requests.csv'
    common_options

    desc "pull_requests", "List who has made pull requests to what repositories in an organization."
    def pull_requests
      TeachersPet::Actions::PullRequests.new(options).run
    end
  end
end
