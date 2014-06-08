module TeachersPet
  class Cli
    option :organization, required: true
    option :repository, required: true
    option :clone_method, default: 'https', desc: "'https' or 'ssh'"

    students_option
    common_options

    desc 'clone_repos', "Clone all student repositories for a particular assignment into the current directory."
    def clone_repos
      TeachersPet::Actions::CloneRepos.new(options).run
    end
  end
end
