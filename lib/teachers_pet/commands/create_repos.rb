module TeachersPet
  class Cli
    option :organization, required: true
    option :repository, required: true
    option :public, type: :boolean, desc: "Make the repositories public"
    option :init_files, type: :boolean, desc: "Add .gitignore and README.md files? Skip this if you are pushing starter files."

    students_option
    instructors_option
    common_options

    desc 'create_repos', "Create assignment repositories for students."
    def create_repos
      TeachersPet::Actions::CreateRepos.new(options).run
    end
  end
end
