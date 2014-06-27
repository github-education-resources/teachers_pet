module TeachersPet
  class Cli
    option :repository, required: true, banner: 'OWNER/REPO'
    common_options

    desc 'merge_pull_requests', "Merges all open pull requests on a particular repository"
    def merge_pull_requests
      TeachersPet::Actions::MergePullRequests.new(options).run
    end
  end
end
