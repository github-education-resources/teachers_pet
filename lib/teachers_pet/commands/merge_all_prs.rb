module TeachersPet
  class Cli
    option :organization, required: true
    option :repository, required: true, banner: 'OWNER/REPO'
    common_options

    desc 'merge_all_open_prs', "Merges all open pull requests on a particular repository"
    def merge_all_open_prs
      TeachersPet::Actions::MergeAllPrs.new(options).run
    end
  end
end
