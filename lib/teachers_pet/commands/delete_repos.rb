module TeachersPet
  class Cli
    option :organization, required: true
    option :repository, required: true

    students_option
    common_options

    desc 'delete_repos', "Delete students' assignment repositories."
    def delete_repos
      TeachersPet::Actions::DeleteRepos.new(options).run
    end
  end
end
