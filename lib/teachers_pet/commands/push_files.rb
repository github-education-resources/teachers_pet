module TeachersPet
  class Cli
    option :organization, required: true
    option :repository, required: true

    students_option
    common_options
    option :ssh, banner: 'HOST', default: TeachersPet::Configuration.sshEndpoint

    desc 'push_files', "Run this command from a local Git repository to push the files up to the specified repository for each student. It will add a remote that is the name of each student team to your repository."
    def push_files
      TeachersPet::Actions::PushFiles.new(options).run
    end
  end
end
