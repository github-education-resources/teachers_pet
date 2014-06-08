module TeachersPet
  class Cli
    option :organization, required: true
    option :repository, required: true
    option :clone_method, default: 'https', desc: "'https' or 'ssh'"

    option :students, default: TeachersPet::Configuration.studentsFile, banner: 'PATH', desc: "The path to the file containing the list of students"

    common_options

    desc "open_issue", "Clone all student repositories for a particular assignment into the current directory."
    def clone_repos
      TeachersPet::Actions::CloneRepos.new(options).run
    end
  end
end
