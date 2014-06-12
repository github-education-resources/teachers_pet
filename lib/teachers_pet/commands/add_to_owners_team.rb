module TeachersPet
  class Cli
    option :organization, required: true

    option :members, default: TeachersPet::Configuration.instructorsFile, banner: 'PATH', desc: "The path to the file containing the list of instructors"
    common_options

    desc 'add_to_owners_team', "Add each user in the list to the Owners team on the specified organization."
    def add_to_owners_team
      TeachersPet::Actions::AddToOwnersTeam.new(options).run
    end
  end
end
