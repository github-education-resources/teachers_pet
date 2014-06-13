module TeachersPet
  class Cli
    option :organization, required: true

    students_option
    common_options

    desc 'create_student_teams', "Create teams for each student (or student group), and a team for all the instructors."
    def create_student_teams
      TeachersPet::Actions::CreateStudentTeams.new(options).run
    end
  end
end
