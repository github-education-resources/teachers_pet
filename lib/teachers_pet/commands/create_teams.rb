module TeachersPet
  class Cli
    option :organization, required: true

    students_option
    option :instructors, default: TeachersPet::Configuration.instructorsFile, banner: 'PATH', desc: "The path to the file containing the list of instructors"
    common_options

    desc 'create_teams', "Create teams for each student (or student group), and a team for all the instructors."
    def create_teams
      TeachersPet::Actions::CreateTeams.new(options).run
    end
  end
end
