module TeachersPet
  class Cli
    option :repository, required: true, banner: 'OWNER/REPO'
    option :output, banner: 'PATH', default: 'students.csv'
    common_options

    desc "forks", "Pull the list of users who have forked a particular repository."
    def forks
      TeachersPet::Actions::Forks.new(options).run
    end
  end
end
